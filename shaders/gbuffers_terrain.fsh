#version 330 compatibility

#include "/lib/color.glsl"

in vec2 vTexcoord;
in vec2 vLmcoord;
in vec4 vColor;
in vec3 vNormal;
in vec3 vPos;

uniform sampler2D texture;

/* DRAWBUFFERS:012 */
// 0: Base Color (RGBA8)
// 1: Normal (RGBA16F)
// 2: Lightmap (RGBA16F)

void main() {
    vec4 albedo = texture2D(texture, vTexcoord) * vColor;

    // Alpha test (discard transparent pixels)
    if (albedo.a < 0.1) discard;

    // Output Base Color to colortex0
    gl_FragData[0] = srgbToLinear(albedo);

    // Output Normal to colortex1
    gl_FragData[1] = vec4(vNormal, 1.0);

    // Output Lightmap to colortex2
    float emission = 0.0;
    gl_FragData[2] = vec4(vLmcoord.x, vLmcoord.y, emission, gl_FragCoord.z);
}
