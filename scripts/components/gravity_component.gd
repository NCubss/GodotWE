class_name GravityComponent
extends Component
## Provides customizable gravity.

## The gravity. By default, this is the [code]default_gravity[/code] project
## setting multiplied by the [code]default_gravity_vector[/code].
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s²")
var gravity: Vector2 = default()
## The maximum fall speed.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var max_fall_speed := 258.0


## Returns the default gravity value from the project settings as a vector.
static func default() -> Vector2:
	return (
		ProjectSettings.get_setting("physics/2d/default_gravity_vector")
		* ProjectSettings.get_setting("physics/2d/default_gravity")
	)


func _physics_process(_delta: float) -> void:
	# absolute cinema
	owner.velocity += gravity
	if owner.velocity.y > max_fall_speed:
		owner.velocity.y = max_fall_speed
