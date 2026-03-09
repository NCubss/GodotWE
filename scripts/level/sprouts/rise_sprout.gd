class_name RiseSprout
extends Sprout

@export var item: PackedScene
@export var texture: Texture2D


func _ready() -> void:
	%Sprite.texture = texture


func end_sprout(direction: Vector2) -> SproutReturnData:
	%Sprite.visible = true
	%Sound.play()
	var tween = %Sprite.create_tween()
	# shadow fix
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(%Sprite, "position", direction * 16, 0.5)
	tween.finished.connect(_die)
	var data = SproutReturnData.new()
	data.new_tile = preload("uid://vxvp8itjp1cv")
	return data


func _die() -> void:
	if item != null:
		var node = item.instantiate()
		node.position = position + Vector2(0, -8)
		get_parent().add_child(node)
	if %Sound.playing:
		await %Sound.finished
	queue_free()
