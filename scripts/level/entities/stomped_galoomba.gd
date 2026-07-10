class_name StompedGaloomba
extends Entity

const DECEL = 10.2


func _physics_process(_delta: float) -> void:
	super(_delta)
	if %PickupComponent.held:
		velocity = Vector2.ZERO
		return
	var old_velocity = velocity
	move_and_slide()
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, DECEL)
		if old_velocity.y >= 30:
			velocity.y = old_velocity.y / -2.0
	velocity.x = clamp(velocity.x, -240, 240)
