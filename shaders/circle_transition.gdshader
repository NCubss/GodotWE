shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform vec4 transition_color : source_color;
uniform float smoothness : hint_range(0.0, 5.0) = 1.0;
uniform float progress : hint_range(0.0, 1.0);

void fragment() {
	ivec2 size = textureSize(SCREEN_TEXTURE, 0);
	
}
