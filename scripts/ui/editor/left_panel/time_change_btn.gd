class_name TimeChangeBtn
extends TextureButton

const SOUND_UP = preload("uid://ymeql5livmqb")
const SOUND_DOWN = preload("uid://be16yxppbt7re")

const SOUND_DELAY = 0.6
const STEP_DELAY = 0.1

var step_timer = INF
var sound_timer = INF


func _process(delta: float) -> void:
	step_timer -= delta
	sound_timer -= delta
	
	if button_pressed and %Editor.level != null:
		
		if step_timer <= 0:
			var old = %Editor.level.time
			%Editor.level.time += -10 if flip_v else 10
			if old == %Editor.level.time:
				step_timer = INF
				sound_timer = INF
			else:
				step_timer = STEP_DELAY
		
		if sound_timer <= 0:
			%TimeSounds.stream = SOUND_DOWN if flip_v else SOUND_UP
			%TimeSounds.play()
			sound_timer = SOUND_DELAY
		
	else:
		step_timer = INF
		sound_timer = INF


func _pressed() -> void:
	step_timer = 0
	sound_timer = 0
