class_name LevelActionBtn
extends Button

@onready var _effect: ButtonHoverEffect

@export var action: LevelView.Action


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
			var level = Level.from_swe(owner.path)
			level.status = Level.Status.EDITING
			SceneManager.fade_to_node(level)
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
