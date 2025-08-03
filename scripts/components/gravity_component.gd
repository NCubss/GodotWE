class_name GravityComponent
extends Component
## Provides customizable gravity.

## The gravity. By default, this is the [code]default_gravity[/code] project
## setting multiplied by the [code]default_gravity_vector[/code].
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s²")
var gravity: Vector2 = (
	ProjectSettings.get_setting("physics/2d/default_gravity_vector") * Vector2(
		ProjectSettings.get_setting("physics/2d/default_gravity"),
		ProjectSettings.get_setting("physics/2d/default_gravity")
	)
)
## The maximum fall speed.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var max_fall_speed := 258.0


func _physics_process(_delta: float) -> void:
	# absolute cinema
	owner.velocity += gravity
	if owner.velocity.y > max_fall_speed:
		owner.velocity.y = max_fall_speed
