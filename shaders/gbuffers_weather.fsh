#version 330 compatibility

#include "/lib/color.glsl"

in vec2 vTexcoord;
in vec2 vLmcoord;
in vec4 vColor;
in vec3 vNormal;

uniform sampler2D texture;

/* DRAWBUFFERS:012 */
// Material ID 6.0 = Weather/Rain

void main() {
    vec4 albedo = texture2D(texture, vTexcoord) * vColor;
    if (albedo.a < 0.1) discard;

    // We output weather to colortex0
    gl_FragData[0] = vec4(srgbToLinear(albedo.rgb), albedo.a);

    // Output normal with ID 6.0 to prevent it from casting dark shadows on itself
    gl_FragData[1] = vec4(vNormal, 6.0);

    gl_FragData[2] = vec4(vLmcoord.x, vLmcoord.y, 0.0, gl_FragCoord.z);
}
