class_name QuestionBlockPart
extends Part


static func get_category() -> PaletteCategory:
	return load("uid://wtetnd7c3nmk")


static func get_part_icon(_environment: SubArea) -> Texture2D:
	return preload("uid://ditkrlf2ksiwo")


static func is_multiplaceable() -> bool:
	return true


static func create() -> QuestionBlockPart:
	return load("uid://b7i6hre4grgbn").instantiate()


func build() -> void:
	var tile = preload("uid://c4qpbj5epsp55").instantiate()
	tile.position = position
	sub_area.add(tile)
