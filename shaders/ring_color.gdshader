shader_type canvas_item;

uniform sampler2D shadow;
uniform vec4 color : source_color;

void fragment() {
	vec4 src = texture(TEXTURE, UV);
	COLOR.rgb = mix(
		vec3(src.r),
		vec3(1) - ((vec3(1) - vec3(src.r)) * (vec3(1) - color.rgb)),
		vec3(src.b)
	);
	COLOR = mix(texture(shadow, UV), COLOR, src.a);
}
