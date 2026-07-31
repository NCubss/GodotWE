class_name CoursebotPopoutBtn
extends Button

enum Type {
	SAVE_NEW,
	SAVE_CHANGES,
	LOAD,
}

@export var type: Type

@onready var _effect := ButtonHoverEffect.new(self)


func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _draw() -> void:
	_effect.draw()


func _pressed() -> void:
	%CoursebotPanel.close()
	%CoursebotPanel.sound_player.stream = preload("uid://c7niodexb50qw")
	%CoursebotPanel.sound_player.play()
	match type:
		Type.SAVE_NEW:
			pass
		Type.SAVE_CHANGES:
			pass
		Type.LOAD:
			pass


func _mouse_entered() -> void:
	if not DisplayServer.is_touchscreen_available():
		UISoundPlayer.stream = preload("uid://bbc6fa1b5njqq")
		UISoundPlayer.play()
	_effect.start()


func _mouse_exited() -> void:
	_effect.stop()
