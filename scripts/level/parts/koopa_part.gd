class_name KoopaPart
extends Part


static func get_category() -> PaletteCategory:
	return load("uid://bisixphutjm6u")


static func get_part_icon(_environment: SubArea) -> Texture2D:
	return preload("uid://i6yqrkdrb4c8")


static func create() -> Part:
	return load("uid://c88or32e26655").instantiate()


func build() -> void:
	var koopa = preload("uid://bhbedk8m2yflb").instantiate()
	sub_area.get_foreground().add_child(koopa)
	koopa.global_position = global_position + Vector2(8, 16)
	koopa.level = level
	koopa.sub_area = sub_area
