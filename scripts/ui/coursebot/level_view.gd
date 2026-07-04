class_name LevelView
extends PanelContainer

enum Action {
	EDIT,
	PLAY,
	EXPORT,
	RENAME,
}

@onready var close_btn_effect := ButtonHoverEffect.new(%CloseBtn)

var coursebot: Coursebot
var path: String:
	set = _set_path
var level: Level:
	set = _set_level


static func create(_coursebot: Coursebot, _path: String,
		_level := Level.from_swe(_path, true)) -> LevelView:
	var view = preload("uid://bdytsrr80hbee").instantiate()
	view.coursebot = _coursebot
	view.path = _path
	view.level = _level
	return view


func _ready() -> void:
	SceneManager.transition_started.connect(func coursebot_transition():
		mouse_behavior_recursive = MOUSE_BEHAVIOR_DISABLED)
	%CloseBtn.mouse_entered.connect(close_btn_effect.start)
	%CloseBtn.mouse_exited.connect(close_btn_effect.stop)
	%CloseBtn.pressed.connect(close)
	


func close() -> void:
	coursebot.transition(coursebot.main_page, true)


func _set_path(v: String) -> void:
	path = v
	%Size.text = String.humanize_size(FileAccess.get_size(path))


func _set_level(v: Level) -> void:
	level = v
	%Name.text = level.level_name
	%Author.text = level.author
	var stamp: Texture2D
	match level.tag_1:
		Level.Tag.STANDARD:
			stamp = preload("uid://85dh255fk01f")
		Level.Tag.PUZZLE_SOLVING:
			stamp = preload("uid://b0y0ga3nvpacn")
		Level.Tag.SPEEDRUN:
			stamp = preload("uid://c4xtndnarix0d")
		Level.Tag.AUTOSCROLL:
			stamp = preload("uid://dxlrsljdwatli")
		Level.Tag.AUTO_MARIO:
			stamp = preload("uid://dnl0c5g8kgv2q")
		Level.Tag.SHORT_AND_SWEET:
			stamp = preload("uid://d2d3vpwsqvshl")
		Level.Tag.MULTIPLAYER_VERSUS:
			stamp = preload("uid://8x7nngqqer0s")
		Level.Tag.THEMED:
			stamp = preload("uid://c2pqbkpva0eme")
		Level.Tag.MUSIC:
			stamp = preload("uid://ba17tkoc651fy")
		Level.Tag.ART:
			stamp = preload("uid://bvi0xscvllvks")
		Level.Tag.TECHNICAL:
			stamp = preload("uid://btwtv0iq8bij")
		Level.Tag.SHOOTER:
			stamp = preload("uid://bv5060idle3mr")
		Level.Tag.BOSS_BATTLE:
			stamp = preload("uid://b28uew6aferch")
		Level.Tag.SINGLEPLAYER:
			stamp = preload("uid://b6tkfw4h2jb6q")
		Level.Tag.LINK:
			stamp = preload("uid://bs5mde40gmhhh")
	if stamp != null:
		%Stamp.texture = stamp
	%CreationDate.text = level.creation_date
	%CreationTime.text = level.creation_time
	%ClearCondition.text = level.ClearCondition.find_key(level.clear_condition)
	%Tag.text = tr("TAG_%s" % Level.Tag.find_key(level.tag_2))
	var style: Texture2D
	match level.game_style:
		Level.GameStyle.SMB:
			style = preload("uid://ct7nsivikgx8h")
		Level.GameStyle.SMB3:
			style = preload("uid://ce4hyhrbcmjlt")
		Level.GameStyle.SMW:
			style = preload("uid://b548gpt5xh0v2")
		Level.GameStyle.NSMBU:
			style = preload("uid://upsn5uu41qe6")
	if style != null:
		%GameStyle.texture = style
	%Description.text = level.description
