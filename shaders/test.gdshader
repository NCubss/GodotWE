shader_type canvas_item;

uniform vec4 background_color : source_color;
uniform vec4 shadow_color : source_color;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
// Currently pixels always in application size, so zooming in further wouldn't increase the size of the dropdown
// but changing that would also be relatively trivial
uniform vec2 offset_in_pixels;

void fragment() {
	
	// Read screen texture
	vec4 current_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	
	// Check if the current color is our background color
	if (length(current_color - background_color) < 0.01) {
		
		vec4 offset_color = textureLod(SCREEN_TEXTURE, SCREEN_UV - offset_in_pixels * SCREEN_PIXEL_SIZE, 0.0);
		
		// Check if at our offset position we have a color which is not the background (meaning here we need a shadow actually)
		if (length(offset_color - background_color) > 0.01) {
			// If so set it to our shadow color
			current_color = shadow_color;
		}
	}
	
	COLOR = current_color;
}