shader_type canvas_item;

uniform vec4 input_color : hint_color;

void fragment() {
	// Combine the the texture color of this fragment with the input color
	COLOR = texture(TEXTURE, UV).rgba * input_color;
}