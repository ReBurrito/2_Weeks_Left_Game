shader_type canvas_item;

uniform float noise_intensity : hint_range(0.0, 1.0) = 0.05;
uniform float static_speed : hint_range(0.0, 1.0) = 0.01;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    float n = random(UV + (TIME * static_speed));
    vec3 static_rgb = vec3(n);
    COLOR = vec4(static_rgb, noise_intensity);
}