class_name DeadEntity
extends Node2D
## Represents a dead entity.

## The rotation speed in degrees. For the dead entity to turn, its horizontal
## velocity must not be 0 as the direction is dependant on the sign of it.
@export_custom(PROPERTY_HINT_NONE, "°/s")
var rotation_speed := 960.0
## The gravity.
@export_custom(PROPERTY_HINT_NONE, "px/s²")
var gravity := Vector2(0, 12)
## The current velocity, or the initial velocity if set from the editor, In the
## latter case, expect this value to be modified when the node is ready.
@export_custom(PROPERTY_HINT_NONE, "px/s")
var velocity := Vector2(0, -240)
## The maximum vertical speed when going down.
@export_custom(PROPERTY_HINT_NONE, "px/s")
var max_y_speed := 240.0


func _init() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	reset_physics_interpolation.call_deferred()
	z_index = GameConstants.Layers.Z_DEAD
	name = &"DeadEntity"
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	velocity += gravity
	velocity.y = minf(velocity.y, max_y_speed)
	position += velocity * delta
	rotation_degrees += rotation_speed * delta
