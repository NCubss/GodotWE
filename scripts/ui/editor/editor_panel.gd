class_name EditorPanel
extends Control
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
@export var move_for_eraser := true
## The current [enum Status] of this panel.
@export var status := Status.OPEN:
	set(v):
		if v == status:
			return
		status = v
		_extend_tween = create_tween()
		var pos: Vector2
		match v:
			Status.OPEN:
				pos = open_pos
				mouse_behavior_recursive = MOUSE_BEHAVIOR_INHERITED
			Status.CLOSED:
				pos = closed_pos
				mouse_behavior_recursive = MOUSE_BEHAVIOR_DISABLED
			Status.HIDDEN:
				pos = hidden_pos
				mouse_behavior_recursive = MOUSE_BEHAVIOR_DISABLED
		_extend_tween.tween_property(self, "position", pos, 0.1)

var _extend_tween: Tween
var _pre_erase_status: Status


func _ready() -> void:
	if move_for_eraser:
		%Editor.erase_started.connect(_erase_started)
		%Editor.erase_stopped.connect(_erase_stopped)
	else:
		set_process(false)


func _process(_delta: float) -> void:
	if %Editor.erasing != Editor.EraseMode.NONE \
			and _pre_erase_status == Status.OPEN:
		if Rect2(open_pos, size).has_point(
				get_parent().get_local_mouse_position()):
			status = Status.CLOSED
		else:
			status = Status.OPEN


func _erase_started() -> void:
	_pre_erase_status = status


func _erase_stopped() -> void:
	status = _pre_erase_status
