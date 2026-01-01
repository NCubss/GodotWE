extends Label


func _process(delta: float) -> void:
	text = str(int(Engine.get_frames_per_second()))
