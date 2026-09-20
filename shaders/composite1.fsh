#version 330 compatibility

in vec2 texcoord;
uniform sampler2D colortex0; // Lit Scene

/* DRAWBUFFERS:0 */

void main() {
    vec4 color = texture2D(colortex0, texcoord);
    gl_FragData[0] = color;
}
