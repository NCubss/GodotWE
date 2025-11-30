shader_type canvas_item;

uniform float progress;
uniform vec2 tile_size;
uniform vec2 texture_size;


void fragment() {
	vec2 size = tile_size / texture_size;
	float ratio = texture_size.x / texture_size.y;
	vec2 segment = vec2(
		(floor(UV.x / size.x) * size.x),
		(floor(UV.y / size.y) * size.y)
	);
	float angle = radians(45);
	float prog = smoothstep((segment.x + segment.y) / 2.0, (segment.x + segment.y + size.x + size.y) / 2.0, progress);
	mat2 rotate = mat2(vec2(cos(angle), -sin(angle)),
						vec2(sin(angle), cos(angle)));
	mat2 scale = mat2(vec2(1.0 / prog, 0), vec2(0, 1));
	vec2 new_uv = (UV - segment - (size / 2.0)) * vec2(ratio, 1) * inverse(rotate) * scale * rotate * vec2(1.0 / ratio, 1);
	if (new_uv == clamp(new_uv, size / -2.0, size / 2.0)) {
		COLOR = texture(TEXTURE, new_uv + segment + (size / 2.0));
	} else {
		COLOR = vec4(0, 0, 0, 0);
	}
}