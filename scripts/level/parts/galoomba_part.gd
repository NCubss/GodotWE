class_name GaloombaPart
extends Part


static func get_category() -> PaletteCategory:
	return load("uid://wtetnd7c3nmk")


static func get_part_icon(_environment: SubArea) -> Texture2D:
	return preload("uid://bj6fwc6kp3nf")


static func create() -> GaloombaPart:
	return load("uid://bqogj600unc0d").instantiate()


func build() -> void:
	var galoomba = preload("uid://d2p4v7v1baic6").instantiate()
	galoomba.global_position = global_position + Vector2(8, 16)
	sub_area.add(galoomba)
