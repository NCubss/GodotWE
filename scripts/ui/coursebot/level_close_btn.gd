class_name LevelCloseBtn
extends TextureButton

@onready var _effect := ButtonHoverEffect.new(self)


func _ready() -> void:
	mouse_entered.connect(_effect.start)
	mouse_exited.connect(_effect.stop)


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _draw() -> void:
	_effect.draw()


func _pressed() -> void:
	UISoundPlayer.stream = preload("uid://5m44h24yoh7l")
	UISoundPlayer.play()
	owner.close()
