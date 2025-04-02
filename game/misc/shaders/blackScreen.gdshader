shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.5) = 0.0; // 0 = fully black, 1+ = full reveal
uniform vec2 center = vec2(0.5, 0.5); // Center of the effect (normalized UV)
uniform vec2 screen_size = vec2(1920.0, 1080.0); // Default screen size, override in code

void fragment() {
    vec2 uv_corrected = (UV - center) * vec2(screen_size.x / screen_size.y, 1.0);
    float dist = length(uv_corrected);

    if (dist < radius) {
        discard; // Make the circle transparent
    }

    COLOR = vec4(0.0, 0.0, 0.0, 1.0); // Keep the rest black
}