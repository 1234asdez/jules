#version 330 compatibility

in vec2 vTexcoord;
in vec4 vColor;

uniform sampler2D texture;

void main() {
    vec4 albedo = texture2D(texture, vTexcoord) * vColor;
    if (albedo.a < 0.1) discard;
    gl_FragData[0] = albedo;
}
