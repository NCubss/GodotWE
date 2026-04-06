class_name Particle
extends AnimatedSpriteExt


func _ready() -> void:
	animation_finished.connect(queue_free)
