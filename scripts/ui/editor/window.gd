class_name EditorWindow
extends PanelContainer

signal selected(id: StringName)

var part: Part
var target_position: Vector2

var _mouse_in := false


func _ready() -> void:
	%SoundPlayer.play()
	position = (target_position * 3) - get_combined_pivot_offset()
	mouse_entered.connect(func(): _mouse_in = true)
	mouse_exited.connect(func(): _mouse_in = false)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1).from(Vector2(0, 0))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not _mouse_in:
		if event.pressed:
			close()


func select(id: StringName) -> void:
	selected.emit(id)
	close()


func close() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2(0, 0), 0.1)
	tween.tween_callback(queue_free)
