shader_type canvas_item;
uniform float flash_amount = 0.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    tex_color.rgb = mix(tex_color.rgb, vec3(1.0), flash_amount); // Blend with white
    COLOR = tex_color;
}