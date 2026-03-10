extends AudioStreamPlayer
## Used for playing various UI sounds.


func _init() -> void:
	max_polyphony = 1


## @deprecated: Not much point
func start(path: String) -> void:
	stream = load(path)
	play()
