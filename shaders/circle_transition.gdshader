// author: NCubs
shader_type canvas_item;

uniform vec2 size;
uniform vec2 center = vec2(0.5);
// Optimization when the shader isn't necessary.
uniform bool active = false;
// These values are computed each frame in the SceneManager instead of in the
// shader.
uniform float radius;
uniform float smoothness;

void fragment() {
	if (active) {
		vec2 p = (UV - center) * vec2(size.x / size.y, 1.0);
		float mask = smoothstep(radius - smoothness, radius, length(p));
		COLOR.a *= mask;
	}
}