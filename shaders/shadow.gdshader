shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	//vec2 shadow_uv = SCREEN_UV + (SCREEN_PIXEL_SIZE * vec2(9));
	//COLOR = texture(screen_texture, SCREEN_UV + vec2(0.01));
	COLOR = vec4(1, 0, 0, 1);
}
