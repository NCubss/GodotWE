class_name DeadEntity
extends Node2D

var velocity: Vector2


func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(self, "rotation", 0, 0)
	tween.tween_property(self, "rotation", TAU, 2/3.0)
	tween.set_loops()
	var grav_comp = GravityComponent.new()
	add_child(grav_comp)
	grav_comp.owner = self


func _physics_process(delta: float) -> void:
	position += velocity * delta
