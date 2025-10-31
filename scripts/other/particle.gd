class_name Particle
extends AnimatedSprite2D

func _ready() -> void:
	animation_finished.connect(queue_free)
