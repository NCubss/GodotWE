extends Camera2D

const SPD = 100


func _physics_process(delta: float) -> void:
	position.x += SPD * delta * Input.get_axis("player_left", "player_right")
	position.y += SPD * delta * Input.get_axis("player_up", "player_down")
