#version 330 compatibility

out vec2 vTexcoord;
out vec2 vLmcoord;
out vec4 vColor;
out vec3 vNormal;

void main() {
    vTexcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vLmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vColor    = gl_Color;
    vNormal = normalize(gl_NormalMatrix * gl_Normal);

    gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
}
