class_name RiseSprout
extends Sprout

@export var item: PackedScene
@export var texture: Texture2D
@export var offset: Vector2


func end_sprout(position: Vector2, direction: Vector2) -> void:
	var sprouter = Sprouter.new()
	sprouter.item = item.instantiate()
	sprouter.texture = texture
	sprouter.global_position = position + (Vector2(-8, -8) * direction)
	sprouter.pos = position
	sprouter.dir = direction
	sprouter.off = offset
	body.add_sibling(sprouter)
	empty = true


class Sprouter extends Sprite2D:
	var pos: Vector2
	var dir: Vector2
	var off: Vector2
	var item: Node
	var audio := AudioStreamPlayer.new()
	
	
	func _ready() -> void:
		z_index = GameConstants.Layers.Z_SPROUT
		add_child(audio)
		audio.stream = preload("uid://bexd6cvyd4onk")
		audio.play()
		var tween = create_tween()
		tween.tween_property(self, "global_position", pos + (Vector2(8, 8) * dir), 0.5)
		tween.tween_callback(_spawn)
	
	
	func _spawn() -> void:
		item.global_position = global_position + off
		add_sibling(item)
		if audio.playing:
			hide()
			await audio.finished
		queue_free()
