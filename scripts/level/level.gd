class_name Level
extends Node2D
## Represents a level.

## Emitted when the level timer ends.
signal times_up
## Emitted when the game style changes.
signal game_style_changed(old: GameStyle)
signal playing
signal editing

enum Status {
	PLAYING,
	EDITING,
}

## Represents a game style. Applies across the entire level.
enum GameStyle {
	## The "Super Mario Bros." game style.
	SMB,
	## The "Super Mario Bros. 3" game style.
	SMB3,
	## The "Super Mario World" game style.
	SMW,
	## The "New Super Mario Bros. U" game style.
	NSMBU,
}

## Represents a level theme. Applies only in sub-areas (see [member
## SubArea.level_theme]).
enum LevelTheme {
	OVERWORLD,
	UNDERGROUND,
	UNDERWATER,
	CASTLE,
	SKY,
	AIRSHIP,
	DESERT,
	SNOW,
	MANSION,
	FOREST,
	FALL,
	BEACH,
	MOUNTAIN,
}

## The speed at which the water/lava rises and sinks.
enum WaterSpeed {
	SLOW,
	MEDIUM,
	FAST,
}

## The speed the autoscroll will scroll at.
enum Autoscroll {
	NONE,
	SLOW,
	NORMAL,
	FAST,
}

## Represents a clear condition type.
enum ClearCondition {
	NONE,
	NO_DAMAGE,
	DONT_LAND_ON_GROUND,
	WATER_ONLY,
	NO_COINS,
}

## Represents a level tag.
enum Tag {
	## No tag.
	NONE,
	## "Standard" tag.
	STANDARD,
	## "Puzzle-solving" tag.
	PUZZLE_SOLVING,
	## "Speedrun" tag.
	SPEEDRUN,
	## "Autoscroll" tag.
	AUTOSCROLL,
	## "Auto-Mario" tag.
	AUTO_MARIO,
	## "Short and Sweet" tag.
	SHORT_AND_SWEET,
	## "Multiplayer Versus" tag.
	MULTIPLAYER_VERSUS,
	## "Themed" tag.
	THEMED,
	## "Music" tag.
	MUSIC,
	## "Art" tag.
	ART,
	## "Technical" tag.
	TECHNICAL,
	## "Shooter" tag.
	SHOOTER,
	## "Boss battle" tag.
	BOSS_BATTLE,
	## "Single player" tag.
	SINGLEPLAYER,
	## "Link" tag.
	LINK
}

const GRID_SIZE = Vector2(16, 16)
## The maximum level height in tiles.
const LEVEL_HEIGHT = 27

## The current status of the level.
@export var status: Status
## The name of the level.
@export var level_name: String
## The level author's username. This is used to determine if the player can edit
## this level.
@export var author: String
## The first tag of the level.
@export var tag_1: Tag = Tag.STANDARD
## The second tag of the level.
@export var tag_2: Tag = Tag.NONE
## The description of the level, with a maximum of 92 characters. Attempting to
## set a string of higher length will cut it to the first 92 characters.
@export_multiline var description := "":
	set(v):
		description = v.substr(0, 92)
## The game style of the level. See [member SubArea.game_theme] for the game
## theme.
@export var game_style := GameStyle.SMW:
	set(v):
		var old = game_style
		game_style = v
		game_style_changed.emit(old)
## The level's timer, in seconds. The player is forcibly killed once it arrives
## to zero. This may violate the Geneva Convention.
@export_range(10, 500, 10) var time := 430:
	set(value):
		time = clamp(value, 10, 500)
## The clear condition for this level.
@export var clear_condition := ClearCondition.NONE
## The current [SubArea], that is, the [SubArea] in which entities are active
## and the player is in.
@export var current_sub_area: SubArea
## Whether this level is on the title screen.
@export var title_screen := false
## The [Editor] this level is associated with. If this level is not editable,
## this will be [code]null[/code] and an error will be pushed if level editing
## is attempted.
@export var editor: Editor
## The online level ID for this level. Empty if this level [b]is not[/b] being
## played online. See [member file_path] for the local counterpart.
@export var online_id := ""
## The path to the file that represents this level. Empty if this level
## [b]is[/b] being played online. See [member online_id] for the online
## counterpart.
@export var file_path := ""
## The author's local time when this level was saved in the format "HH:MM".
## Empty if unknown. Using this as a level creation timestamp can be unreliable
## as this is saved as a string and can be tampered, leading to possible parse
## errors.
@export var creation_time := ""
## The date when this level was saved in the format "DD/MM/YYYY". Empty if
## unknown. Using this as a level creation timestamp can be unreliable as this
## is saved as a string and can be tampered, leading to possible parse errors.
@export var creation_date :=  ""

## The level's automatically assigned sub-areas.
var sub_areas: Array[SubArea] = []
## The [HUD] associated with this level. Hidden while editing.
var hud: HUD


static func to_grid(pos: Vector2) -> Vector2i:
	return Vector2i((pos / GRID_SIZE).floor())


static func from_grid(pos: Vector2i) -> Vector2:
	return Vector2(pos) * GRID_SIZE


static func snap(pos: Vector2) -> Vector2:
	return (pos / GRID_SIZE).floor() * GRID_SIZE


func _init(_level_name := "", _author := "", _game_style := GameStyle.SMW):
	game_style = _game_style
	level_name = _level_name
	author = _author


func _ready() -> void:
	hud = load(GameConstants.HUDS[game_style]).instantiate()
	hud.level = self
	add_child(hud)
	for i in get_children():
		if i is SubArea:
			sub_areas.append(i)
			i.level = self
			i.load()
	assert(not sub_areas.is_empty(), "Level does not have any sub-areas.")
	if current_sub_area == null:
		current_sub_area = sub_areas[0]
	if editor != null:
		editor.level = self
		editor.load()
	if status == Status.PLAYING:
		_play()
	elif status == Status.EDITING:
		create_editor()
		_edit()
	Utility.camera_scale = Vector2(3, 3)


func _process(_delta: float) -> void:
	_camera_clamp.call_deferred()


func create_editor() -> void:
	if editor != null:
		return
	var editor_layer = preload("uid://cjcx6mlu5ad62").instantiate()
	add_child(editor_layer)
	editor = editor_layer.get_node(^"%Editor")
	editor.level = self
	editor.load()


## Starts the level.
func play() -> void:
	if status == Status.PLAYING:
		return
	_play()
	playing.emit()


func edit() -> void:
	if status == Status.EDITING:
		return
	_edit()
	editing.emit()


func get_current_time() -> int:
	if %LevelTimer.is_stopped():
		return 0
	else:
		return int(%LevelTimer.time_left)


func reload() -> void:
	# :)
	edit()
	Utility.camera_position_raw = Vector2(0, -get_viewport().get_visible_rect().size.y)
	play()


func _camera_clamp() -> void:
	Utility.camera_position_raw = Utility.camera_position_raw.clamp(
			Vector2(0, -LEVEL_HEIGHT * GRID_SIZE.y * Utility.camera_scale.y),
			Vector2(INF, -get_viewport().get_visible_rect().size.y))


func _timeout() -> void:
	times_up.emit()
	#player.kill()


func _play() -> void:
	status = Status.PLAYING
	%LevelTimer.start(time + 1)
	hud.show()
	if title_screen:
		var date = Time.get_datetime_dict_from_system()
		if date.month == Time.MONTH_DECEMBER:
			if date.day == 24 or date.day == 25:
				MusicPlayer.stream = preload("uid://bn00oxygr85n7")
			else:
				MusicPlayer.stream = preload("uid://6x74u4b7w0al")
		else:
			match game_style:
				GameStyle.SMB:
					MusicPlayer.stream = preload("uid://dha58dtfupqng")
				GameStyle.SMB3:
					MusicPlayer.stream = preload("uid://dha58dtfupqng")
				GameStyle.SMW:
					MusicPlayer.stream = preload("uid://bxnvgrgxf685m")
				GameStyle.NSMBU:
					MusicPlayer.stream = preload("uid://chlmxxg0dw2t3")
	else:
		MusicPlayer.stream = preload("uid://c7xx82tvew4nu")
	MusicPlayer.play()


func _edit() -> void:
	status = Status.EDITING
	process_mode = Node.PROCESS_MODE_INHERIT
	%LevelTimer.stop()
	hud.hide()
	MusicPlayer.stop()
