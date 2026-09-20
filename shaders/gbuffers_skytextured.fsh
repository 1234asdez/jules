#version 330 compatibility

in vec2 vTexcoord;
in vec4 vColor;

uniform sampler2D texture;

/* DRAWBUFFERS:0 */

void main() {
    vec4 albedo = texture2D(texture, vTexcoord) * vColor;
    if (albedo.a < 0.1) discard;

    // Output sun/moon directly to colortex0
    gl_FragData[0] = albedo;
}
