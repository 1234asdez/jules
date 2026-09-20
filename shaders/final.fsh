#version 330 compatibility

#include "/lib/color.glsl"

in vec2 texcoord;
uniform sampler2D colortex0;

/* DRAWBUFFERS:0 */

// Simple 9-tap gaussian blur for bloom
vec3 getBloom(sampler2D tex, vec2 uv, float radius) {
    vec2 texelSize = 1.0 / vec2(1920.0, 1080.0); // Approximation, ideal would use viewWidth/Height
    vec3 bloom = vec3(0.0);
    float weights[9] = float[](0.05, 0.09, 0.12, 0.15, 0.18, 0.15, 0.12, 0.09, 0.05);

    for (int x = -4; x <= 4; x++) {
        for (int y = -4; y <= 4; y++) {
            vec2 offset = vec2(float(x), float(y)) * texelSize * radius;
            vec3 sampleColor = texture2D(tex, uv + offset).rgb;

            // Extract bright spots for bloom (thresholding)
            float brightness = dot(sampleColor, vec3(0.2126, 0.7152, 0.0722));
            if (brightness > 1.5) {
                bloom += sampleColor * weights[x+4] * weights[y+4];
            }
        }
    }
    return bloom;
}

void main() {
    vec4 color = texture2D(colortex0, texcoord);

    // Apply simple bloom
    vec3 bloomAmount = getBloom(colortex0, texcoord, 2.0) + getBloom(colortex0, texcoord, 4.0);
    vec3 combinedColor = color.rgb + bloomAmount * 0.15; // Mix bloom into base

    // Slightly lower exposure to compensate for brighter lighting in composite
    float exposure = 1.05;
    vec3 mapped = combinedColor * exposure;

    // Contrast adjustment before tonemapping
    mapped = pow(mapped, vec3(1.1));

    mapped = acesFilm(mapped);
    mapped = linearToSrgb(mapped);

    gl_FragData[0] = vec4(mapped, 1.0);
}
