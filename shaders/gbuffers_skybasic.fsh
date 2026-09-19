#version 330 compatibility

#include "/lib/color.glsl"

in vec2 vTexcoord;
in vec4 vColor;

uniform int worldTime;

/* DRAWBUFFERS:0 */

void main() {
    bool isDay = (worldTime < 13000 || worldTime > 23000);

    // Calculate basic sky and light colors based on time
    vec3 zenithColor = isDay ? vec3(0.1, 0.3, 0.6) : vec3(0.01, 0.02, 0.05);
    vec3 horizonColor = isDay ? vec3(0.5, 0.7, 0.9) : vec3(0.05, 0.1, 0.2);

    // Sunset / Sunrise logic
    float sunsetFactor = 0.0;
    if (worldTime > 12000 && worldTime < 14000) {
        sunsetFactor = 1.0 - abs(worldTime - 13000.0) / 1000.0;
    } else if (worldTime > 22000 || worldTime < 1000) {
        float timeMod = worldTime > 22000 ? worldTime - 24000.0 : worldTime;
        sunsetFactor = 1.0 - abs(timeMod + 1000.0) / 1000.0;
    }

    if (sunsetFactor > 0.0) {
        vec3 sunsetColor = vec3(1.0, 0.4, 0.1);
        horizonColor = mix(horizonColor, sunsetColor, sunsetFactor);
    }

    // We can use screen coordinates to create a vertical gradient
    // Since we don't have viewHeight passed in, we can just use vColor as a base
    // or calculate a simple gradient based on the vertex position, but for a skybox,
    // simply blending our horizon color with the vanilla sky (which has a gradient) looks okay.
    // Let's just output our calculated horizon/sunset color and let the sky textured pass draw sun/moon over it.

    gl_FragData[0] = vec4(horizonColor, 1.0);
}
