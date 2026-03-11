class_name PageBtn
extends Button

enum Page {
	EDITOR,
	COURSEBOT,
	ENDLESS,
	ONLINE,
}

const SCN_EDITOR = preload("uid://cbc3kaegk4jn3")
const SCN_COURSEBOT = preload("uid://cbc3kaegk4jn3")
const SCN_ENDLESS = preload("uid://cbc3kaegk4jn3")
const SCN_ONLINE = preload("uid://cbc3kaegk4jn3")

@export var page: Page

var _effect: ButtonHoverEffect


func _ready() -> void:
	_effect = ButtonHoverEffect.new(self)
	mouse_entered.connect(_mouse.bind(true))
	mouse_exited.connect(_mouse.bind(false))
	get_tree().scene_changed.connect(_scene_changed)
	_scene_changed()


func _get_scn() -> PackedScene:
	match page:
		Page.EDITOR:
			return SCN_EDITOR
		Page.COURSEBOT:
			return SCN_COURSEBOT
		Page.ENDLESS:
			return SCN_ENDLESS
		Page.ONLINE:
			return SCN_ONLINE
		_:
			return PackedScene.new()


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _mouse(state: bool) -> void:
	if state:
		UISoundPlayer.stream = preload("uid://dn2weik3slobr")
		UISoundPlayer.play()
		_effect.start()
	else:
		_effect.stop()


func _scene_changed() -> void:
	var path = get_tree().current_scene.scene_file_path
	if path != "":
		button_pressed = _get_scn() == load(get_tree().current_scene.scene_file_path)


func _toggled(toggled_on: bool) -> void:
	if toggled_on and load(get_tree().current_scene.scene_file_path) != _get_scn():
		if page == Page.ONLINE:
			%MenuPlayer.stream = preload("uid://druyd4ts46cgu")
			%MenuPlayer.play()
			%LoginLayer.show()
		else:
			%MenuPlayer.stream = preload("uid://c1ddsd1m5j2lh")
			%MenuPlayer.play()
			SceneManager.fade_to_scene(_get_scn())


func _draw() -> void:
	_effect.draw()
