#version 330 compatibility

#include "/lib/color.glsl"
#include "/lib/lighting.glsl"
#include "/lib/math.glsl"

in vec2 texcoord;

uniform sampler2D colortex0; // Base Color
uniform sampler2D colortex1; // Normal + Material ID
uniform sampler2D colortex2; // Lightmap + Depth
uniform sampler2D depthtex0; // Depth buffer
uniform sampler2D shadowtex0; // Shadow map depth
uniform sampler2D shadowcolor0; // Shadow map color

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform int worldTime;

/* DRAWBUFFERS:0 */

vec3 getScreenSpacePosition(vec2 coord, float depth) {
    vec3 clipSpace = vec3(coord, depth) * 2.0 - 1.0;
    vec4 viewSpace = gbufferProjectionInverse * vec4(clipSpace, 1.0);
    return viewSpace.xyz / viewSpace.w;
}

float getShadow(vec3 worldPos) {
    vec4 shadowViewPos = shadowModelView * vec4(worldPos, 1.0);
    vec4 shadowProjPos = shadowProjection * shadowViewPos;

    shadowProjPos.xy = distortShadowSpace(shadowProjPos.xy);
    shadowProjPos.z *= 0.2;

    vec3 shadowCoord = shadowProjPos.xyz * 0.5 + 0.5;

    if (shadowCoord.x < 0.0 || shadowCoord.x > 1.0 || shadowCoord.y < 0.0 || shadowCoord.y > 1.0 || shadowCoord.z < 0.0 || shadowCoord.z > 1.0) {
        return 1.0;
    }

    float shadow = 0.0;
    vec2 texelSize = 1.0 / vec2(2048.0);

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            float depth = texture2D(shadowtex0, shadowCoord.xy + vec2(x, y) * texelSize).r;
            // Greatly reduced the bias to prevent the shadow from being offset downwards.
            // When we do projPos.z *= 0.2 in the shadow vertex shader, the depth range is highly compressed.
            // A bias of 0.002 was acting like a 2.5-block offset.
            shadow += (shadowCoord.z - 0.00005 > depth) ? 0.0 : 1.0;
        }
    }

    return shadow / 9.0;
}

void main() {
    vec4 baseColor = texture2D(colortex0, texcoord);
    vec4 normalData = texture2D(colortex1, texcoord);
    vec4 lmData = texture2D(colortex2, texcoord);
    float depth = texture2D(depthtex0, texcoord).r;

    if (depth == 1.0) {
        vec3 skyColor = mix(vec3(0.5, 0.7, 0.9), vec3(0.1, 0.3, 0.6), texcoord.y);
        gl_FragData[0] = vec4(skyColor, 1.0);
        return;
    }

    vec3 normal = normalData.rgb;
    float materialID = normalData.a;
    vec2 lmcoord = lmData.rg;

    vec3 viewPos = getScreenSpacePosition(texcoord, depth);
    vec3 worldPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

    bool isDay = (worldTime < 13000 || worldTime > 23000);

    // The MOST reliable way to align lighting perfectly with shadows:
    // Extract the light direction directly from the shadow transformation matrix.
    // The shadowModelView maps world coordinates to shadow view space, where +Z points away from the light.
    // So the light vector in world space is the Z row of the shadowModelView matrix.
    vec3 worldLightDir = normalize(vec3(shadowModelView[0][2], shadowModelView[1][2], shadowModelView[2][2]));

    // Transform light direction to view space to match our normal
    // We use gbufferModelView (not Inverse) to go from World Space -> View Space
    vec3 lightDir = normalize((mat3(gbufferModelView) * worldLightDir));

    vec3 lightColor = isDay ? vec3(1.0, 0.95, 0.85) : vec3(0.15, 0.25, 0.45);

    float nDotL = lambert(normal, lightDir);

    float shadow = 1.0;
    if (nDotL > 0.0) {
        shadow = getShadow(worldPos);
    }

    float diffuse = clamp(nDotL * 0.5 + 0.5, 0.0, 1.0);

    vec3 directIllum = lightColor * diffuse * shadow;
    vec3 indirectIllum = getLightmapColor(lmcoord);

    vec3 finalColor = baseColor.rgb * (directIllum + indirectIllum);

    if (materialID == 4.0) {
        vec3 viewDir = normalize(-viewPos);
        vec3 halfDir = normalize(lightDir + viewDir);
        float spec = pow(max(dot(normal, halfDir), 0.0), 64.0);
        finalColor += spec * lightColor * shadow;
    }

    // If it is a cloud (materialID == 5.0), bypass shadows and diffuse lighting
    if (materialID == 5.0) {
        finalColor = baseColor.rgb; // Render clouds fully bright / original color
    }

    gl_FragData[0] = vec4(finalColor, baseColor.a);
}
