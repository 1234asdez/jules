#version 330 compatibility

#include "/lib/math.glsl"

out vec2 vTexcoord;
out vec2 vLmcoord;
out vec4 vColor;
out vec3 vNormal;
out vec3 vPos;

uniform float frameTimeCounter;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

// Iris block entity mapping
attribute vec3 mc_Entity;

void main() {
    vTexcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vLmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vColor    = gl_Color;

    // Calculate standard normal
    vNormal = normalize(gl_NormalMatrix * gl_Normal);

    // Transform position to view space
    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;

    // Transform to world space for waving logic
    vec4 worldPos = gbufferModelViewInverse * viewPos;
    vec3 absPos = worldPos.xyz + cameraPosition;

    // Basic waving animation for foliage/grass
    // mc_Entity.x is populated via block.properties
    // 31.0 = grass/wheat/ferns, 18.0 = leaves
    bool isGrass = abs(mc_Entity.x - 31.0) < 0.1;
    bool isLeaves = abs(mc_Entity.x - 18.0) < 0.1;

    if (isGrass || isLeaves) {
        float waveSpeed = 1.5;
        float waveStrength = isLeaves ? 0.03 : 0.08; // Leaves sway less than tall grass

        // Use absolute world position to prevent "swimming" effect as player moves
        float wave = sin(frameTimeCounter * waveSpeed + absPos.x + absPos.z) * waveStrength;
        wave += sin(frameTimeCounter * waveSpeed * 1.3 + absPos.x * 2.0) * (waveStrength * 0.5);

        // Sway more near the top. We use the texture coordinate V (gl_MultiTexCoord0.y)
        // which is usually ~0 at the top of a block and ~1 at the bottom in Minecraft.
        // Wait, Minecraft V coords: 0 is top, 1 is bottom. So we want (1.0 - V) for grass to sway at top.
        // For leaves, we just sway the whole block a little bit, or use a general noise.
        float swayMultiplier = isGrass ? (1.0 - clamp(gl_MultiTexCoord0.y, 0.0, 1.0)) : 1.0;

        worldPos.x += wave * swayMultiplier;
        worldPos.z += wave * swayMultiplier * 0.5; // Slight diagonal sway
    }

    // Back to view space
    viewPos = gbufferModelView * worldPos;
    vPos = viewPos.xyz;

    // Final projection
    gl_Position = gl_ProjectionMatrix * viewPos;
}
