class_name MiniBtn
extends TextureButton

enum Type {
	## Opens the Settings once pressed.
	SETTINGS,
	## Logs out of online once pressed.
	LOGOUT,
	## Goes to the title screen once pressed.
	TITLE,
}

## The type of behavior this button should have.
@export var type: Type

@onready var _effect := ButtonHoverEffect.new(self,
		Rect2(0, 0, size.x, size.y - 6))


func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _pressed() -> void:
	match type:
		Type.TITLE:
			UISoundPlayer.stream = preload("uid://e1c77rl0cw86")
			UISoundPlayer.play()
			SceneManager.fade_to_scene(preload("uid://d11xvcdkd38jq"))


func _draw() -> void:
	_effect.draw()


func _mouse_entered() -> void:
	if not DisplayServer.is_touchscreen_available():
		UISoundPlayer.stream = preload("uid://dmdnc6gaj44mv")
		UISoundPlayer.play()
	_effect.start()


func _mouse_exited() -> void:
	_effect.stop()
