class_name StompedGaloomba
extends Entity

@onready var pickup_component: PickupComponent = Utility.find_child_by_class(
		self, PickupComponent)


func _physics_process(_delta: float) -> void:
	super(_delta)
	if not pickup_component.held:
		var old_velocity = velocity
		move_and_slide()
		if old_velocity.y >= 30 and is_on_floor():
			velocity.y = old_velocity.y / -2
			prints("Bounce!", Engine.get_frames_drawn())
	else:
		velocity = Vector2.ZERO
