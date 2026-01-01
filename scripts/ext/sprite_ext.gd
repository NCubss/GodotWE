class_name SpriteExt
extends Sprite2D

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
	#if texture == null:
		#return
	#var matrix = global_transform.translated(offset)
	#if centered:
		#matrix = matrix.translated(
				#global_transform.basis_xform(texture.get_size() / -2))
	#matrix = matrix.translated(shadows.offset)
	#matrix = matrix.scaled(Vector2(-1 if flip_h else 1, -1 if flip_v else 1))
	#shadows.draw_set_transform_matrix(matrix)
	#shadows.draw_texture(texture, Vector2.ZERO)
