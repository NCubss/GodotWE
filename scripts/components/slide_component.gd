class_name SlideComponent
extends Component
## Provides sliding and turning around behavior.
## 
## Entities that use this type of movement include Goombas, Koopas, Mushrooms,
## 1-UPs, etc.

## The speed the node will move at.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var speed := 60.0

var _direction := 1


func _physics_process(_delta: float) -> void:
	if get_parent().is_on_wall():
		_direction *= -1
	get_parent().velocity.x = speed * _direction
