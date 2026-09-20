#version 330 compatibility

in vec2 vTexcoord;
in vec4 vColor;

uniform sampler2D texture;

/* DRAWBUFFERS:012 */
// 0: Base Color (RGBA8)
// 1: Normal (RGBA16F)
// 2: Lightmap (RGBA16F)

void main() {
    vec4 albedo = texture2D(texture, vTexcoord) * vColor;
    if (albedo.a < 0.1) discard;

    gl_FragData[0] = albedo;

    // Output default up-normal. Material ID = 5.0 for clouds
    gl_FragData[1] = vec4(0.0, 1.0, 0.0, 5.0);

    // Output full bright lightmap (1.0, 1.0) so they aren't darkened ambiently
    gl_FragData[2] = vec4(1.0, 1.0, 0.0, gl_FragCoord.z);
}
