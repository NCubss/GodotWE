class_name AnimatedSpriteExt
extends AnimatedSprite2D
## @deprecated: 

#var shadows: Shadows
#
#
#func _notification(what: int) -> void:
	#match what:
		#NOTIFICATION_ENTER_CANVAS:
			#if shadows == null:
				#shadows = Utility.id("shadows") as Shadows
			#shadows.draw.connect(_draw_self)
			#print("entered")
		#NOTIFICATION_EXIT_CANVAS:
			#shadows.draw.disconnect(_draw_self)
			#print("exited")
#
#
#func _draw_self() -> void:
	#if sprite_frames == null:
		#return
	#var texture = sprite_frames.get_frame_texture(animation, frame)
	#var flips = Vector2(-1.0 if flip_h else 1.0, -1.0 if flip_v else 1.0)
	#var matrix = global_transform\
			#.scaled(flips) \
			#.translated(shadows.offset) \
			#.translated(global_transform.basis_xform(texture.get_size() / -2) if centered else Vector2.ZERO)
	#shadows.draw_set_transform_matrix(matrix)
	#shadows.draw_texture(texture, Vector2.ZERO)
