shader_type spatial;

uniform sampler2D heightmap;

void vertex() {
	float tx = texture(heightmap, VERTEX.xz).x;
	VERTEX.y += tx;
}

void fragment() {
	//ALBEDO = vec3(smoothstep(0, 1, dot(normalize(CAMERA_DIRECTION_WORLD), normalize(TANGENT))));
	ALBEDO = vec3(NORMAL_MAP_DEPTH);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
