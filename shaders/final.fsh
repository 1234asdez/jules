#version 330 compatibility

#include "/lib/color.glsl"

in vec2 texcoord;
uniform sampler2D colortex0;

/* DRAWBUFFERS:0 */

void main() {
    vec4 color = texture2D(colortex0, texcoord);

    float exposure = 1.2;
    vec3 mapped = color.rgb * exposure;
    mapped = acesFilm(mapped);
    mapped = linearToSrgb(mapped);

    gl_FragData[0] = vec4(mapped, 1.0);
}
