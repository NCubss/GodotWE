class_name CoinPart
extends Part


static func get_category() -> PaletteCategory:
	return load("uid://d15pdc5d1rkwr")


static func get_part_icon(_environment: SubArea) -> Texture2D:
	return preload("uid://c7m37apuxw0qu")


static func is_multiplaceable() -> bool:
	return true


static func create() -> CoinPart:
	return load("uid://cxu0namx61nsi").instantiate()


func build() -> void:
	var coin = preload("uid://dt15xtlk2twqj").instantiate()
	coin.global_position = global_position
	sub_area.add(coin)
