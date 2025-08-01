// author: NCubs
shader_type canvas_item;

uniform vec2 zoom_factor = vec2(3.0);
uniform vec4 shadow_color : source_color = vec4(0, 0, 0, 0.3);
uniform vec2 shadow_offset = vec2(3.0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 original = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 shadow = vec4(shadow_color.rgb, texture(
		SCREEN_TEXTURE,
		SCREEN_UV - SCREEN_PIXEL_SIZE * zoom_factor * shadow_offset
	).a * shadow_color.a);
	COLOR = mix(shadow, original, original.a);
}
