@icon("uid://dgfxxtttchbse")
class_name SlideComponent
extends Component
## Provides sliding and turning around behavior.
## 
## Entities that use this type of movement include Goombas, Koopas, Mushrooms,
## 1-UPs, etc.

## Triggered when the node hits a wall and turns around.
signal turned(direction: Vector2)

## The speed the node will move at.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var speed := 60.0
## The current direction as a speed multiplier. [code]-1[/code] is left,
## [code]1[/code] is right.
var direction := -1

var _started := false


func _physics_process(_delta: float) -> void:
	if get_parent().is_on_floor():
		_started = true
	if _started:
		if get_parent().is_on_wall():
			direction *= -1
			if direction == 1:
				turned.emit(Vector2.RIGHT)
			elif direction == -1:
				turned.emit(Vector2.LEFT)
		get_parent().velocity.x = speed * direction
