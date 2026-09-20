#ifndef COLOR_GLSL
#define COLOR_GLSL

// sRGB to Linear
vec3 srgbToLinear(vec3 c) {
    return pow(c, vec3(2.2));
}

vec4 srgbToLinear(vec4 c) {
    return vec4(pow(c.rgb, vec3(2.2)), c.a);
}

// Linear to sRGB
vec3 linearToSrgb(vec3 c) {
    return pow(c, vec3(1.0 / 2.2));
}

vec4 linearToSrgb(vec4 c) {
    return vec4(pow(c.rgb, vec3(1.0 / 2.2)), c.a);
}

// ACES Tone Mapping Operator
vec3 acesFilm(vec3 x) {
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

#endif // COLOR_GLSL
