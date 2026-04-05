class_name TurnBlockPart
extends Part


static func get_category() -> PaletteCategory:
	return load("uid://wtetnd7c3nmk")


static func get_part_icon(_environment: SubArea) -> Texture2D:
	return preload("uid://ykxo18kl82fw")


static func is_multiplaceable() -> bool:
	return true


static func create() -> TurnBlockPart:
	return load("uid://k7sykscno8vb").instantiate()


func build() -> void:
	var tile = preload("uid://d1pyovyuwelpw").instantiate()
	tile.global_position = global_position
	sub_area.add(tile)
