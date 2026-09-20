#ifndef LIGHTING_GLSL
#define LIGHTING_GLSL

// Calculate basic diffuse lighting (Lambert)
float lambert(vec3 normal, vec3 lightDir) {
    return max(dot(normal, lightDir), 0.0);
}

// Blocklight and Skylight calculations based on lightmap coordinates
vec3 getLightmapColor(vec2 lmcoord) {
    // Torchlight is the X component, Skylight is the Y component

    // Better attenuation for torch light
    float torchLight = max(0.0, lmcoord.x - 0.05); // slightly compress darks
    torchLight = pow(torchLight, 2.4); // gamma-like curve

    // Smooth skylight
    float skyLight = pow(lmcoord.y, 2.0);

    // Warmer, brighter torch color
    vec3 torchColor = vec3(1.0, 0.65, 0.25) * torchLight * 3.0;

    // Brighter ambient sky color to prevent pitch-black shadows in daylight
    vec3 skyColor = mix(vec3(0.05, 0.08, 0.12), vec3(0.3, 0.4, 0.5), skyLight);

    return torchColor + skyColor;
}

// Calculate shadow distortion for improved shadow map utilization
vec2 distortShadowSpace(vec2 pos) {
    float len = length(pos);
    float distortion = mix(1.0, len, 0.8);
    return pos / distortion;
}

#endif // LIGHTING_GLSL
