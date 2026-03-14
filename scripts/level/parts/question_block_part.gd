class_name QuestionBlockPart
extends Part


func build() -> void:
	var tile = preload("uid://c4qpbj5epsp55").instantiate()
	tile.position = position
	sub_area.add(tile)
