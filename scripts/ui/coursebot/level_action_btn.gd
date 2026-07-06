class_name LevelActionBtn
extends Button

signal _level_loaded

@onready var _effect: ButtonHoverEffect

@export var action: LevelView.Action

var _level: Level


func _enter_tree() -> void:
	if get_parent() is Container:
		await get_parent().sort_children
	_effect = ButtonHoverEffect.new(self)
	mouse_entered.connect(_effect.start)
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_effect.stop)


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _draw() -> void:
	_effect.draw()


func _toggled(toggled_on: bool) -> void:
	if not toggled_on:
		return
	match action:
		LevelView.Action.EDIT:
			UISoundPlayer.stream = preload("uid://xgqdhf77bhmt")
			# Wrapping this in a lambda to wait for the level asynchronously
			var level_load = func coursebot_level_edit_async():
				_level = await LevelProcessor.from_swe(owner.path)
				_level.status = Level.Status.EDITING
				_level_loaded.emit()
			level_load.call()
			SceneManager.fade_to_callback(func coursebot_level_switch_async():
				if _level == null:
					await _level_loaded
				return _level)
		LevelView.Action.PLAY:
			UISoundPlayer.stream = preload("uid://e1c77rl0cw86")
		LevelView.Action.EXPORT:
			UISoundPlayer.stream = preload("uid://xgqdhf77bhmt")
		LevelView.Action.RENAME:
			UISoundPlayer.stream = preload("uid://xgqdhf77bhmt")
	UISoundPlayer.play()


func _mouse_entered() -> void:
	UISoundPlayer.stream = preload("uid://bbc6fa1b5njqq")
	UISoundPlayer.play()
