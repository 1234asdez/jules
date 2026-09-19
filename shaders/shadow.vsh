#version 330 compatibility

#include "/lib/math.glsl"
#include "/lib/lighting.glsl"

out vec2 vTexcoord;
out vec4 vColor;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform float frameTimeCounter;
uniform mat4 shadowModelViewInverse;
uniform vec3 cameraPosition;

attribute vec3 mc_Entity;

void main() {
    vTexcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vColor = gl_Color;

    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;

    bool isGrass = abs(mc_Entity.x - 31.0) < 0.1;
    bool isLeaves = abs(mc_Entity.x - 18.0) < 0.1;

    if (isGrass || isLeaves) {
        // In the shadow pass, gl_ModelViewMatrix is shadowModelView.
        // We use shadowModelViewInverse to get back to camera-relative world space.
        vec4 worldPos = shadowModelViewInverse * viewPos;
        vec3 absPos = worldPos.xyz + cameraPosition;

        float waveSpeed = 1.5;
        float waveStrength = isLeaves ? 0.03 : 0.08;

        float wave = sin(frameTimeCounter * waveSpeed + absPos.x + absPos.z) * waveStrength;
        wave += sin(frameTimeCounter * waveSpeed * 1.3 + absPos.x * 2.0) * (waveStrength * 0.5);

        // Use local Y for grass to pin the bottom
        float localY = fract(absPos.y - 0.01);
        float swayMultiplier = isGrass ? localY : 1.0;

        worldPos.x += wave * swayMultiplier;
        worldPos.z += wave * swayMultiplier * 0.5;

        viewPos = shadowModelView * worldPos;
    }

    vec4 projPos = gl_ProjectionMatrix * viewPos;

    // Distort shadow coordinates to give more resolution near the camera
    projPos.xy = distortShadowSpace(projPos.xy);

    // We scale the Z slightly to prevent near/far clipping issues after distortion
    projPos.z *= 0.2;

    gl_Position = projPos;
}
