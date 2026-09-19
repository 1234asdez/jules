#version 330 compatibility

#include "/lib/math.glsl"

out vec2 vTexcoord;
out vec2 vLmcoord;
out vec4 vColor;
out vec3 vNormal;
out vec3 vPos;
out vec3 vWorldPos;

uniform float frameTimeCounter;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

void main() {
    vTexcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vLmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vColor    = gl_Color;

    vNormal = normalize(gl_NormalMatrix * gl_Normal);

    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    vec4 worldPos = gbufferModelViewInverse * viewPos;
    vec3 absPos = worldPos.xyz + cameraPosition;

    if (vNormal.y > 0.9) {
        float waveSpeed = 2.0;
        float waveStrength = 0.08;
        float wave = sin(frameTimeCounter * waveSpeed + absPos.x * 2.0 + absPos.z * 1.5) * waveStrength;
        wave += cos(frameTimeCounter * waveSpeed * 0.8 + absPos.x * 1.2 - absPos.z * 2.1) * (waveStrength * 0.5);
        worldPos.y += wave;
    }

    vWorldPos = worldPos.xyz;

    viewPos = gbufferModelView * worldPos;
    vPos = viewPos.xyz;

    gl_Position = gl_ProjectionMatrix * viewPos;
}
