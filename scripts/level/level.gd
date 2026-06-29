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
	Vector2(80, 144),
	Vector2(0, 96),
	Vector2(80, 112),
	Vector2(80, 96),
	Vector2(0, 176),
	Vector2(0, 112),
	Vector2(64, 112),
	Vector2(64, 176),
	Vector2(0, 80),
	Vector2(0, 0),
	Vector2(80, 0),
	Vector2(80, 80),
	Vector2(0, 128),
	Vector2(16, 112),
	Vector2(64, 128),
	Vector2(16, 176),
	Vector2(0, 160),
	Vector2(0, 144),
	Vector2(0, 16),
	Vector2(32, 112),
	Vector2(48, 112),
	Vector2(16, 0),
	Vector2(64, 144),
	Vector2(64, 160),
	Vector2(80, 16),
	Vector2(32, 176),
	Vector2(48, 176),
	Vector2(16, 80),
	Vector2(16, 128),
	Vector2(64, 32),
	Vector2(64, 48),
	Vector2(48, 48),
	Vector2(48, 32),
	Vector2(32, 128),
	Vector2(16, 144),
	Vector2(48, 128),
	Vector2(16, 160),
	Vector2(64, 64),
	Vector2(48, 64),
	Vector2(32, 144),
	Vector2(32, 160),
	Vector2(48, 160),
	Vector2(48, 144),
	Vector2(80, 160),
	Vector2(80, 128),
	Vector2(16, 96),
	Vector2(32, 16),
	Vector2(48, 16),
	Vector2(64, 16),
	Vector2(32, 96),
	Vector2(48, 96),
	Vector2(64, 96),
	Vector2(32, 0),
	Vector2(48, 0),
	Vector2(64, 0),
	Vector2(32, 80),
	Vector2(48, 80),
	Vector2(64, 80),
	Vector2(0, 32),
	Vector2(0, 48),
	Vector2(0, 64),
	Vector2(80, 32),
	Vector2(80, 48),
	Vector2(80, 64),
	Vector2(16, 32),
	Vector2(32, 32),
	Vector2(16, 48),
	Vector2(32, 48),
	Vector2(16, 64),
	Vector2(32, 64),
]
const SWE_OBJECT_TABLE = {
	"obj_block_res": preload("uid://k7sykscno8vb"),
	"obj_qblock_res": preload("uid://b7i6hre4grgbn"),
	"obj_coin_res": preload("uid://cxu0namx61nsi"),
	"obj_goomba_res": preload("uid://bqogj600unc0d"),
}

## The [Thread] that is used for level saving and loading.
static var thread := Thread.new()

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


static func _static_init() -> void:
	thread.start(_thread)




## Decodes a SWE file's JSON content. The returned array contains two elements:
## a [bool] for whether the hash within the file is correct as an "anti-tamper"
## measure, and the parsed JSON data. Returns an empty array if decoding failed.
## Note that the parsed JSON can be any valid JSON value, however, if
## untampered, the parsed data should always be a [Dictionary].
static func decode_swe(data: PackedByteArray) -> Array:
	print("Decoding SWE file...")
	if data.size() < 41:
		push_error("File is too small")
		return []
	var end_size: int
	if data.decode_u8(data.size() - 1) == 0:
		print("End contains null byte")
		end_size = -1
	else:
		print("End does not contain null byte")
		end_size = 0
	#var stored_hash = file.substr(file.length() - end_size, 40)
	var stored_hash = data.slice(end_size - 40, data.size() + end_size) \
			.get_string_from_utf8()
	var b64 = data.slice(0, end_size - 40)
	var crypto = Crypto.new()
	var json = JSON.new()
	var expected_hash = crypto.hmac_digest(HashingContext.HASH_SHA1,
			SWE_HMAC_KEY.to_utf8_buffer(), b64).hex_encode()
	print("Stored hash: %s" % stored_hash)
	print("Expected hash: %s" % expected_hash)
	var raw = Marshalls.base64_to_utf8(b64.get_string_from_utf8())
	if raw == "":
		push_error("Base64 decoding failed or raw JSON is empty")
		return []
	var err = json.parse(raw)
	if err != OK:
		push_error("JSON parsing failed (%s) at line %d: %s" % [
				err,
				json.get_error_line(),
				json.get_error_message()])
		return []
	print("SWE decoding done!")
	return [stored_hash == expected_hash, json.data]


## Loads a [Level] from an SMM:WE SWE level file. Only loads basic level
## information if [param meta_only] is [code]true[/code]. The loader is very
## lenient and accepts unusual values and missing fields that are only possible
## by tampering. If a value is unusable, it uses the default values.
static func from_swe(path: String, meta_only := false) -> Level:
	#region decoding and preparation
	print_rich("[b]Loading level at path [code]%s[/code]...[/b]" % path)
	var result = decode_swe(FileAccess.get_file_as_bytes(path))
	if result.is_empty():
		push_error("SWE decoding failed during level loading")
		return
	var lvl: Level = load("uid://b16kyjui2n3qv").instantiate()
	if not result[0]:
		push_error("Level file is tampered (hashes do not match)")
		return lvl
	if result[1] is not Dictionary:
		push_error("Expected Dictionary at root, got %s" %
				type_string(typeof(result[1])))
		return lvl
	#endregion
	#region sections
	var data: Dictionary = result[1]
	var wrapper: Dictionary
	var list: Array
	var terrain: Array
	var objects: Array
	
	var _wrapper = _get_value(data, "S0", "MAIN")
	if _wrapper is Dictionary:
		wrapper = _wrapper
	else:
		_warn_type("Wrapper", _wrapper)
		return lvl
		
	var _list = _get_value(wrapper, "S1", "AJUSTES")
	if _list is Array:
		list = _list
	else:
		_warn_type("Settings list", _list)
		return lvl
	
	var _terrain = _get_value(wrapper, "S2", "SUELO")
	if _terrain is Array:
		terrain = _terrain
	else:
		_warn_type("Terrain", _terrain)
		return lvl
	
	var _objects = _get_value(wrapper, "S4", "NIVEL")
	if _objects is Array:
		objects = _objects
	else:
		_warn_type("Objects", _objects)
		return lvl
	#endregion
	#region level metadata
	var map = list[0]
	
	lvl.level_name = path.trim_suffix("." + path.get_extension())
	
	var _author = map.get("user")
	if _author != null:
		lvl.author = str(_author)
	else:
		_warn_type("Author", _author)
	
	var _game_style = _int(_get_value(map, "gamestyle", "apariencia"))
	if _game_style is int and _game_style == clampi(_game_style, 0, 3):
		lvl.game_style = GameStyle.SMW # _game_style as GameStyle
	else:
		_warn_type("Game style", _game_style)
	
	var _description = _get_value(map, "desc", "description")
	if _description != null:
		lvl.description = str(_description)
	else:
		_warn_type("Description", _description)
	#endregion
	#region sub-area metadata
	
	var sub: SubArea = lvl.current_sub_area
	
	var _level_theme = _get_value(map, "gametheme", "entorno")
	if _level_theme != null and str(_level_theme) in SWE_LEVEL_THEME_TABLE:
		sub.level_theme = LevelTheme.OVERWORLD # SWE_LEVEL_THEME_TABLE[str(_level_theme)]
	else:
		_warn_type("Level theme", _level_theme)
	
	
	var _night_mode = _int(_get_value(map, "nightmode", "modo_noche"))
	if _night_mode is int:
		sub.night_mode = false # bool(_night_mode)
	else:
		_warn_type("Night mode", _night_mode)
	#endregion
	if meta_only:
		return lvl
	#region sub-area terrain
	for i in terrain:
		if i is Dictionary:
			var ground: GroundPart = preload("uid://dpfaa6qawfnk1").instantiate()
			sub.add_part(ground)
			ground.owner = lvl
			var xx = _int(_get_value(i, "xx", "x_pos"))
			if xx == null:
				continue
			var yy = _int(_get_value(i, "yy", "y_pos"))
			if yy == null:
				continue
			ground.global_position = snap(Vector2(xx, yy - 432))
			#var idx = _int(_get_value(i, "i", "index"))
			#if idx == null:
				#continue
			#var atlas = SWE_GROUND_FRAME_TABLE.get(idx)
			#ground.atlas(atlas.x, atlas.y)
	
	# TODO: start height: _get_value(map, "start_y", "ground2")
	#endregion
	#region sub-area objects
	for i in objects:
		if i is Dictionary:
			var id = _get_value(i, "ID", "object")
			if id == null:
				continue
			else:
				id = str(id)
			if id not in SWE_OBJECT_TABLE:
				continue
			var xx = _int(_get_value(i, "xx", "x_pos"))
			if xx == null:
				continue
			var yy = _int(_get_value(i, "yy", "y_pos"))
			if yy == null:
				continue
			var scn: PackedScene = SWE_OBJECT_TABLE[id]
			var obj = scn.instantiate()
			obj.global_position = snap(Vector2(xx, yy - 432))
			sub.add_part(obj)
			obj.owner = lvl
	#endregion
	return lvl


static func to_grid(pos: Vector2) -> Vector2i:
	return Vector2i((pos / GRID_SIZE).floor())


static func from_grid(pos: Vector2i) -> Vector2:
	return Vector2(pos) * GRID_SIZE


static func snap(pos: Vector2) -> Vector2:
	return (pos / GRID_SIZE).floor() * GRID_SIZE


static func _warn_type(key: String, value: Variant) -> void:
	push_warning("%s is invalid value %s (type %s)" %
			[key, value, type_string(typeof(value))])
 

static func _get_value(dict: Dictionary, new: String, old: String) -> Variant:
	return dict.get(new if new in dict else old)


static func _int(value: Variant) -> Variant:
	if value is float:
		return roundi(value)
	elif value is String:
		return value.to_int()
	else:
		return null


static func _thread() -> void:
	pass


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
