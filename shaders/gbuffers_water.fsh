#version 330 compatibility

#include "/lib/color.glsl"
#include "/lib/math.glsl"

in vec2 vTexcoord;
in vec2 vLmcoord;
in vec4 vColor;
in vec3 vNormal;
in vec3 vPos;
in vec3 vWorldPos;

uniform sampler2D texture;
uniform float frameTimeCounter;
uniform mat4 gbufferModelView;
uniform vec3 cameraPosition;

/* DRAWBUFFERS:012 */

vec3 getWaterNormal(vec3 worldPos) {
    vec3 absPos = worldPos + cameraPosition;
    vec2 p = absPos.xz * 1.5;
    float time = frameTimeCounter * 1.5;

    float n1 = noise(p + time);
    float n2 = noise(p * 2.0 - time * 1.2);
    float n3 = noise(p * 4.0 + time * 0.8);

    vec2 d = vec2(0.01, 0.0);
    float dx = noise(p + d.xy + time) - n1;
    float dz = noise(p + d.yx + time) - n1;

    vec3 normal = normalize(vec3(-dx, 0.1, -dz));
    return normalize((gbufferModelView * vec4(normal, 0.0)).xyz);
}


void main() {
    vec4 albedo = texture2D(texture, vTexcoord) * vColor;

    vec3 finalNormal = vNormal;
    float materialID = 3.0; // translucents

    if (vNormal.y > 0.9 && albedo.a < 0.95) {
        finalNormal = getWaterNormal(vWorldPos);
        materialID = 4.0; // water
        albedo.rgb *= vec3(0.6, 0.8, 0.9);
        albedo.a = 0.6;
    }

    gl_FragData[0] = vec4(srgbToLinear(albedo.rgb), albedo.a);
    gl_FragData[1] = vec4(finalNormal, materialID);
    gl_FragData[2] = vec4(vLmcoord.x, vLmcoord.y, 0.0, gl_FragCoord.z);
}
