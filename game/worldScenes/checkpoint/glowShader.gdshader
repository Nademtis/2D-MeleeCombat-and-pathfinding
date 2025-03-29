shader_type canvas_item;

uniform vec4 glow_color = vec4(0.87, 0.62, 0.25, 1.0); // Orange #DE9E41
uniform float glow_intensity = 2.5; // Controls glow brightness

void fragment() {
    vec4 sprite_color = texture(TEXTURE, UV);
    
    // Multiply sprite color to make it brighter than 1.0 (needed for bloom)
    vec3 emissive_color = sprite_color.rgb * glow_color.rgb * glow_intensity;

    // Output the bright color (Godot's bloom will handle the glow spread)
    COLOR = vec4(emissive_color, sprite_color.a);
}