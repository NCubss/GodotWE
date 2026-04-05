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
	NO_COINS,
	WATER_ONLY,
	DONT_LAND_ON_GROUND,
	NO_DAMAGE,
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
const SWE_HMAC_KEY = "2559F35097-2021"
const SWE_LEVEL_THEME_TABLE = {
	"ground": LevelTheme.OVERWORLD,
	"underground": LevelTheme.UNDERGROUND,
	"castle": LevelTheme.CASTLE,
	"underwater": LevelTheme.UNDERWATER,
	"desert": LevelTheme.DESERT,
	"ghost": LevelTheme.MANSION,
	"airship": LevelTheme.AIRSHIP,
	"sky": LevelTheme.SKY,
	"forest": LevelTheme.FOREST,
	"snow": LevelTheme.SNOW,
	"beach": LevelTheme.BEACH,
	"fall": LevelTheme.FALL,
	"mountain": LevelTheme.MOUNTAIN,
}
const SWE_GROUND_FRAME_TABLE = [
	Rect2(80, 144, 16, 16),
	Rect2(0, 96, 16, 16),
	Rect2(80, 112, 16, 16),
	Rect2(80, 96, 16, 16),
	Rect2(0, 176, 16, 16),
	Rect2(0, 112, 16, 16),
	Rect2(64, 112, 16, 16),
	Rect2(64, 176, 16, 16),
	Rect2(0, 80, 16, 16),
	Rect2(0, 0, 16, 16),
	Rect2(80, 0, 16, 16),
	Rect2(80, 80, 16, 16),
	Rect2(0, 128, 16, 16),
	Rect2(16, 112, 16, 16),
	Rect2(64, 128, 16, 16),
	Rect2(16, 176, 16, 16),
	Rect2(0, 160, 16, 16),
	Rect2(0, 144, 16, 16),
	Rect2(0, 16, 16, 16),
	Rect2(32, 112, 16, 16),
	Rect2(48, 112, 16, 16),
	Rect2(16, 0, 16, 16),
	Rect2(64, 144, 16, 16),
	Rect2(64, 160, 16, 16),
	Rect2(80, 16, 16, 16),
	Rect2(32, 176, 16, 16),
	Rect2(48, 176, 16, 16),
	Rect2(16, 80, 16, 16),
	Rect2(16, 128, 16, 16),
	Rect2(64, 32, 16, 16),
	Rect2(64, 48, 16, 16),
	Rect2(48, 48, 16, 16),
	Rect2(48, 32, 16, 16),
	Rect2(32, 128, 16, 16),
	Rect2(16, 144, 16, 16),
	Rect2(48, 128, 16, 16),
	Rect2(16, 160, 16, 16),
	Rect2(64, 64, 16, 16),
	Rect2(48, 64, 16, 16),
	Rect2(32, 144, 16, 16),
	Rect2(32, 160, 16, 16),
	Rect2(48, 160, 16, 16),
	Rect2(48, 144, 16, 16),
	Rect2(80, 160, 16, 16),
	Rect2(80, 128, 16, 16),
	Rect2(16, 96, 16, 16),
	Rect2(32, 16, 16, 16),
	Rect2(48, 16, 16, 16),
	Rect2(64, 16, 16, 16),
	Rect2(32, 96, 16, 16),
	Rect2(48, 96, 16, 16),
	Rect2(64, 96, 16, 16),
	Rect2(32, 0, 16, 16),
	Rect2(48, 0, 16, 16),
	Rect2(64, 0, 16, 16),
	Rect2(32, 80, 16, 16),
	Rect2(48, 80, 16, 16),
	Rect2(64, 80, 16, 16),
	Rect2(0, 32, 16, 16),
	Rect2(0, 48, 16, 16),
	Rect2(0, 64, 16, 16),
	Rect2(80, 32, 16, 16),
	Rect2(80, 48, 16, 16),
	Rect2(80, 64, 16, 16),
	Rect2(16, 32, 16, 16),
	Rect2(32, 32, 16, 16),
	Rect2(16, 48, 16, 16),
	Rect2(32, 48, 16, 16),
	Rect2(16, 64, 16, 16),
	Rect2(32, 64, 16, 16),
]
const SWE_OBJECT_TABLE = {
	"obj_block_res": preload("uid://d1pyovyuwelpw"),
	"obj_qblock_res": preload("uid://c4qpbj5epsp55"),
}

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

## The level's automatically assigned sub-areas.
var sub_areas: Array[SubArea] = []
## The [HUD] associated with this level. Hidden while editing.
var hud: HUD


static func from_swe(path: String) -> Level:
	var data = _unpack_swe(path)
	var wrapper: Dictionary
	var list: Array
	var use_s: bool
	if "MAIN" in data:
		# old format
		wrapper = data["MAIN"]
		list = wrapper["AJUSTES"]
		use_s = false
	elif "S0" in data:
		# new format
		wrapper = data["S0"]
		list = wrapper["S1"]
		use_s = true
	else:
		assert(false, "No 'S0' or 'MAIN' found in data")
		return
	var lvl: Level = load("uid://b16kyjui2n3qv").instantiate()
	var map = list[0]
	var use_new: bool
	if "t" in map:
		use_new = map["t"]
	else:
		use_new = false
	assert("user" in map, "No author in metadata")
	lvl.author = map["user"]
	assert(("gamestyle" if use_new else "apariencia") in map,
			"No game style in metadata")
	lvl.game_style = GameStyle.SMW#map["gamestyle" if use_new else "apariencia"]
	if lvl.game_style < 0 or lvl.game_style > 3:
		lvl.game_style = randi_range(0, 3) as GameStyle
	if ("desc" if use_new else "description") in map:
		lvl.description = map["desc" if use_new else "description"]
	var sub: SubArea = lvl.get_node(^"%SubArea0")
	assert(("gametheme" if use_new else "entorno") in map,
			"No level theme in metadata")
	sub.level_theme = LevelTheme.OVERWORLD#SWE_LEVEL_THEME_TABLE[map["gametheme" if use_new else "entorno"]]
	assert(("nightmode" if use_new else "modo_noche") in map,
			"No night mode in metadata")
	sub.night_mode = false#bool(map["nightmode" if use_new else "modo_noche"])
	assert(("timer" if use_new else "cronometro") in map,
			"No time in metadata")
	var _time = map["timer" if use_new else "cronometro"]
	if _time < 10 or _time > 500:
		_time = 300
	lvl.time = _time
	# TERRAIN
	assert(("S2" if use_s else "SUELO") in wrapper, "No terrain data found")
	var terrain: Array = wrapper["S2" if use_s else "SUELO"]
	var fore = sub.get_node(^"%Foreground")
	for i: Dictionary in terrain:
		var ground: GroundTile = preload("uid://bpy1sebdq7k7s").instantiate()
		fore.add_child(ground)
		ground.owner = lvl
		assert(("xx" if use_s else "x_pos") in i, "No X position in terrain tile")
		assert(("yy" if use_s else "y_pos") in i, "No Y position in terrain tile")
		ground.position = Vector2(
				i["xx" if use_s else "x_pos"],
				i["yy" if use_s else "y_pos"] - 432)
		assert(("i" if use_s else "index") in i, "No index in terrain tile")
		var spr: Sprite2D = ground.get_node(^"%Sprite")
		spr.texture.region = SWE_GROUND_FRAME_TABLE[i["i" if use_new else "index"]]
	assert(("start_y" if use_new else "ground2") in map,
			"No start height in metadata")
	var start_height: float = map["start_y" if use_new else "ground2"] - 432
	for x in range(0, 112, 16):
		for y in range(int(start_height), 0, 16):
			var ground = preload("uid://bpy1sebdq7k7s").instantiate()
			fore.add_child(ground)
			ground.owner = lvl
			ground.position = Vector2(x, y)
	var start = Sprite2D.new()
	start.z_as_relative = false
	start.texture = preload("uid://cgslc0o8upncx")
	fore.add_child(start)
	start.owner = lvl
	start.position = Vector2(40, -56)
	# OBJECTS
	var objects: Array = wrapper["S4" if use_s else "NIVEL"]
	for i: Dictionary in objects:
		assert(("ID" if use_s else "object") in i, "No ID in object")
		var id = i["ID" if use_s else "object"]
		if id not in SWE_OBJECT_TABLE:
			continue
		var scn: PackedScene = SWE_OBJECT_TABLE[id]
		var obj = scn.instantiate()
		fore.add_child(obj)
		obj.owner = lvl
		assert(("xx" if use_s else "x_pos") in i, "No X position in object")
		assert(("yy" if use_s else "y_pos") in i, "No Y position in object")
		obj.position = Vector2(
				i["xx" if use_s else "x_pos"],
				i["yy" if use_s else "y_pos"] - 432)
	return lvl


static func _unpack_swe(path: String) -> Dictionary:
	# Ah god I hope there won't be the same problem
	var file = FileAccess.get_file_as_string(path)
	var end_size: int
	# Godot's a dum dum and keeps crying in the output about NUL characters if I
	# type the NUL character any other way
	if file.ends_with(String.chr(0)):
		end_size = 41
	else:
		end_size = 40
	var stored_hash = file.substr(file.length() - end_size, 40)
	var b64 = file.substr(0, file.length() - end_size)
	var crypto = Crypto.new()
	var expected_hash = crypto.hmac_digest(HashingContext.HASH_SHA1,
			SWE_HMAC_KEY.to_utf8_buffer(),
			file.substr(0, file.length() - end_size).to_utf8_buffer()).hex_encode()
	assert(expected_hash == stored_hash, "Tampered level file")
	var data = JSON.parse_string(Marshalls.base64_to_utf8(b64))
	assert(data is Dictionary, "Level file JSON is not an object")
	return data


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
	for i in get_children():
		if i is SubArea:
			sub_areas.append(i)
			i.level = self
			i.load()
	assert(not sub_areas.is_empty(), "Level does not have any sub-areas.")
	if current_sub_area == null:
		current_sub_area = sub_areas[0]
	hud = load(GameConstants.HUDS[game_style]).instantiate()
	hud.level = self
	add_child(hud)
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
		if date["month"] == Time.MONTH_DECEMBER:
			if date["day"] == 24 or date["day"] == 25:
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
