class_name PageBtn
extends Button

enum Page {
	EDITOR,
	COURSEBOT,
	ENDLESS,
	ONLINE,
}

const SCN_EDITOR = preload("uid://cbc3kaegk4jn3")
const SCN_ENDLESS = preload("uid://dtq1i14h6pmvn")
const SCN_ONLINE = preload("uid://h4t4thecwdfc")
const SCN_COURSEBOT = preload("uid://nc2x1hq5ysrg")

@export var page: Page
@export var in_main_menu := true

var _effect: ButtonHoverEffect


func _ready() -> void:
	_effect = ButtonHoverEffect.new(self)
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	if in_main_menu:
		get_tree().scene_changed.connect(_scene_changed)
		_scene_changed()


func _get_scn() -> PackedScene:
	match page:
		Page.EDITOR:
			return SCN_EDITOR
		Page.ENDLESS:
			return SCN_ENDLESS
		Page.ONLINE:
			return SCN_ONLINE
		Page.COURSEBOT:
			return SCN_COURSEBOT
		_:
			return PackedScene.new()


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _mouse_entered() -> void:
	if not DisplayServer.is_touchscreen_available():
		UISoundPlayer.stream = preload("uid://dn2weik3slobr")
		UISoundPlayer.play()
	_effect.start()


func _mouse_exited() -> void:
	_effect.stop()


func _scene_changed() -> void:
	var path = get_tree().current_scene.scene_file_path
	if path != "":
		button_pressed = _get_scn() == load(get_tree().current_scene.scene_file_path)


func _toggled(toggled_on: bool) -> void:
	if toggled_on and load(get_tree().current_scene.scene_file_path) != _get_scn():
		if page == Page.ONLINE:
			MainMenu.menu_player.stream = preload("uid://druyd4ts46cgu")
			MainMenu.menu_player.play()
			%LoginLayer.show()
		else:
			MusicPlayer.stop()
			MainMenu.menu_player.stream = preload("uid://c1ddsd1m5j2lh")
			MainMenu.menu_player.play()
			SceneManager.fade_to_scene(_get_scn())


func _draw() -> void:
	_effect.draw()
