class_name EditorPanel
extends NinePatchRect
## A panel in the editor.

@export var open_pos: Vector2
@export var closed_pos: Vector2

## Whether this panel is extended.
var extended := true:
	set(value):
		if locked:
			push_warning("Trying to extend panel while it is locked.")
			return
		_extend_tween = create_tween()
		_extend_tween.tween_property(self, "position", open_pos if value else closed_pos, 0.1)
		extended = value 

## Whether this panel's extended state can be changed. This is set to
## [code]true[/code] when the palette is opened, camera is zoomed out, etc.
var locked := false

var _extend_tween: Tween


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept"):
		return
	extended = not extended
