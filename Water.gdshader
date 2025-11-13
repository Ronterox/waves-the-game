shader_type spatial;

// -- Water Colors --
uniform vec4 deep_color : source_color = vec4(0.357, 0.608, 0.976, 1.0);
uniform vec4 foam_color : source_color = vec4(0.6, 0.8, 1.0, 1.0);

// -- Wave Controls --
uniform float noise_scale = 256.0;
uniform float time_speed : hint_range(0.0, 1.0) = 0.001;
uniform float foam_hardness : hint_range(0.0, 1.0) = 0.9; // How sharp the edge is
uniform int octaves = 2; // How many layers of noise to add for detail

// --- Shadow and Lighting Controls ---
uniform float shadow_intensity : hint_range(0.0, 1.0) = 0.3; // How much shadows darken the water

// --- Noise Functions (The Magic Behind the Waves) ---

// A simple function to generate a random-ish number from a 2D vector
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// 2D Noise function based on the random one
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in a grid
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smoothly interpolate between the corners
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.y * u.x;
}

// FBM - Fractional Brownian Motion (adds layers of noise)
float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 0.0;

    for (int i = 0; i < octaves; i++) {
        value += amplitude * noise(st);
        st *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// --- Main Fragment Shader ---

void fragment() {
    // Animate the UV coordinates using TIME
    // We create two layers of noise moving in different directions for a more natural look
    vec2 motion1 = vec2(UV.x + TIME * time_speed, UV.y + TIME * time_speed);
    vec2 motion2 = vec2(UV.x - TIME * time_speed, UV.y + TIME * time_speed * 0.5);

    // Calculate two layers of FBM noise and add them together
    float fbm_value = fbm(motion1 * noise_scale) + fbm(motion2 * noise_scale);

    // Use step() to create a hard, cartoony edge between the two colors
    float toon_mask = step(foam_hardness, fbm_value);

    // Mix the two colors based on our toon mask
    vec3 final_color = mix(deep_color.rgb, foam_color.rgb, toon_mask);

    // Apply the final color to the object
    ALBEDO = final_color;

    // Set material properties for lighting
    METALLIC = 0.0;    // Water isn't metallic
    ROUGHNESS = 0.2;   // Make water more reflective (lower roughness)
    ALPHA = 1.0;
}

// Custom light function to control shadow intensity
void light() {
    // Calculate how much shadow there is (ATTENUATION.a contains shadow information)
    float shadow_factor = ATTENUATION;

    // Mix between full brightness and shadow color based on shadow intensity
    // This prevents shadows from completely blacking out the water
    vec3 lit_color = ALBEDO;
    vec3 shadowed_color = ALBEDO * (1.0 - shadow_intensity);

    // Apply the appropriate amount of diffuse light
    DIFFUSE_LIGHT += mix(shadowed_color, lit_color, shadow_factor) * ATTENUATION;
}