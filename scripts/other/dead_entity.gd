class_name DeadEntity
extends CharacterBody2dddddddddddddddddddddddddddddddddddddddD


func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(self, "rotation", 0, 0)
	tween.tween_property(self, "rotation", TAU, 2/3)
	tween.set_loops()
	var grav_comp = GravityComponent.new()
	add_child(grav_comp)
	grav_comp.owner = self
