class_name EditorPanel
extends NinePatchRect
## A panel in the editor.

## Represents a panel state.
enum Status {
	## The panel is open and can be closed.
	OPEN,
	## The panel is closed and can be opened.
	CLOSED,
	## The panel is fully hidden. The user cannot open it.
	HIDDEN,
}

@export var open_pos: Vector2
@export var closed_pos: Vector2
@export var hidden_pos: Vector2
## The current [enum Status] of this panel.
@export var status := Status.OPEN:
	set(v):
		status = v
		_extend_tween = create_tween()
		var pos: Vector2
		match v:
			Status.OPEN:
				pos = open_pos
			Status.CLOSED:
				pos = closed_pos
			Status.HIDDEN:
				pos = hidden_pos
		_extend_tween.tween_property(self, "position", pos, 0.1)

var _extend_tween: Tween
