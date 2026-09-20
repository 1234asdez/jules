#version 330 compatibility

#include "/lib/color.glsl"

in vec2 vTexcoord;
in vec2 vLmcoord;
in vec4 vColor;
in vec3 vNormal;
in vec3 vPos;

uniform sampler2D texture;

/* DRAWBUFFERS:012 */

void main() {
    vec4 albedo = texture2D(texture, vTexcoord) * vColor;
    if (albedo.a < 0.1) discard;
    gl_FragData[0] = vec4(srgbToLinear(albedo.rgb), 1.0);
    gl_FragData[1] = vec4(vNormal, 2.0);
    gl_FragData[2] = vec4(vLmcoord.x, vLmcoord.y, 0.0, gl_FragCoord.z);
}
