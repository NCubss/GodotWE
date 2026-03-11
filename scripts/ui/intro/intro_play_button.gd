class_name IntroPlayButton
extends TextureButton

@onready var _effect = ButtonHoverEffect.new(self)


func _ready() -> void:
	mouse_entered.connect(_effect.start)
	mouse_exited.connect(_effect.stop)


func _pressed() -> void:
	if not SceneManager.fade_in_progress():
		SceneManager.fade_to("uid://d11xvcdkd38jq", SceneManager.Transition.FADE,
				SceneManager.Transition.CIRCLE)


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _draw() -> void:
	_effect.draw()
