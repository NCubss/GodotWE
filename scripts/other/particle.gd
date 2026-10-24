class_name Particle
extends AnimatedSprite2D
## An animated sprite that frees itself once it ends.


func _ready() -> void:
	reset_physics_interpolation.call_deferred()
	animation_finished.connect(queue_free)
