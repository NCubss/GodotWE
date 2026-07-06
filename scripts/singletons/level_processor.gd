extends Node
## Handles [Level] serialization and building with multi-threading.

enum _Command {
	EXIT,
	LOAD,
	SAVE,
	BUILD,
}

signal _done(id: int, data: Variant)

const SWE_HMAC_KEY = "2559F35097-2021"
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

var _thread := Thread.new()
var _semaphore := Semaphore.new()
var _queue: Array[Dictionary] = []
var _queue_mutex := Mutex.new()
var _last_id := 0


func _ready() -> void:
	var err = _thread.start(_run)
	if err != OK:
		OS.alert("GodotWE failed to start the level processor thread: %s. The game cannot continue! Try again later." % error_string(err))
		get_tree().quit(err)


## Decodes a SWE file's JSON content. The returned [Dictionary] contains two
## entries:
## 	• [code]verified[/code] - a [bool] for whether the hash within the file is
## correct as an "anti-tamper" measure;
## 	• [code]data[/code] - the parsed JSON data.
## Returns an empty dictionary if decoding failed.
## [b]Note:[/b] The parsed JSON can be any valid JSON value, however, if
## untampered, the parsed data should always be a [Dictionary].
func decode_swe(data: PackedByteArray) -> Dictionary:
	print("Decoding SWE file...")
	var crypto = Crypto.new()
	var json = JSON.new()
	
	if data.size() < 41:
		push_error("File is too small")
		return {}
	
	var end_size: int
	if data.decode_u8(data.size() - 1) == 0:
		print("End contains null byte")
		end_size = -1
	else:
		print("End does not contain null byte")
		end_size = 0
	
	var b64 = data.slice(0, end_size - 40)
	var stored_hash = data.slice(end_size - 40, data.size() + end_size) \
			.get_string_from_utf8()
	var expected_hash = crypto.hmac_digest(HashingContext.HASH_SHA1,
			SWE_HMAC_KEY.to_utf8_buffer(), b64).hex_encode()
	print("Stored hash: %s" % stored_hash)
	print("Expected hash: %s" % expected_hash)
	
	var raw = Marshalls.base64_to_utf8(b64.get_string_from_utf8())
	if raw == "":
		push_error("Base64 decoding failed or raw JSON is empty")
		return {}
	
	var err = json.parse(raw)
	if err != OK:
		push_error("JSON parsing failed (%s) at line %d: %s" % [
				err,
				json.get_error_line(),
				json.get_error_message()])
		return {}
	
	print("SWE decoding done!")
	return {
		"verified": expected_hash == stored_hash,
		"data": json.data,
	}


## Loads a [Level] from an SMM:WE SWE level file. Only loads basic level
## information if [param meta_only] is [code]true[/code]. The loader is very
## lenient and accepts unusual values and missing fields that are only possible
## by tampering. If a value is unusable, it uses the default values.
func from_swe(path: String, meta_only := false) -> Level:
	return await _request({
		"command": _Command.LOAD,
		"path": path,
		"meta_only": meta_only,
	})
	


func _request(data: Dictionary) -> Variant:
	_last_id += 1
	data.id = _last_id
	_queue_mutex.lock()
	_queue.push_back(data)
	_queue_mutex.unlock()
	_semaphore.post()
	var response: Array
	while true:
		response = await _done
		if response[0] == _last_id:
			break
	return response[1]


func _from_swe(path: String, meta_only := false) -> Level:
	#region decoding and preparation
	print_rich("[b]Loading level at path [code]%s[/code]...[/b]" % path)
	
	var result = decode_swe(FileAccess.get_file_as_bytes(path))
	if result.is_empty():
		push_error("SWE decoding failed during level loading")
		return
	var lvl: Level = preload("uid://b16kyjui2n3qv").instantiate()
	if not result.verified:
		push_error("Level file is tampered (hashes do not match)")
		return lvl
	if result.data is not Dictionary:
		push_error("Expected Dictionary at root, got %s" %
				type_string(typeof(result[1])))
		return lvl
	#endregion
	
	print("Decoding and Preparation DONE")
	
	#region sections
	var data: Dictionary = result.data
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
	
	print("Sections DONE")
	
	#region level metadata
	var map = list[0]
	
	lvl.level_name = path.get_basename().get_file()
	
	lvl.creation_date = str(_get_value(map, "date", "date"))
	lvl.creation_time = str(_get_value(map, "time", "time"))
	
	var _tag_1 = int(_get_value(map, "label_1", "etiqueta1")) + 1 % 14
	var _tag_2 = int(_get_value(map, "label_2", "etiqueta2")) + 1 % 14
	# handling casting manually so 'as' doesn't make a runtime error
	if _tag_1 in Level.Tag.values():
		lvl.tag_1 = _tag_1 as Level.Tag
	if _tag_2 in Level.Tag.values():
		lvl.tag_2 = _tag_2 as Level.Tag
	
	var condition = int(_get_value(map, "c_conditions", "condiciones_count"))
	if condition in Level.ClearCondition.values():
		lvl.clear_condition = condition as Level.ClearCondition
	
	var _author = map.get("user")
	if _author != null:
		lvl.author = str(_author)
	else:
		_warn_type("Author", _author)
	
	#lvl.game_style = clampi(int(_get_value(map, "gamestyle", "apariencia")),
			#0, 3) as GameStyle
	lvl.game_style = Level.GameStyle.SMW
	
	var _description = _get_value(map, "desc", "description")
	if _description != null:
		lvl.description = str(_description)
	else:
		_warn_type("Description", _description)
	#endregion
	
	print("Level Metadata DONE")
	
	#region sub-area metadata
	var sub: SubArea = lvl.current_sub_area
	
	var _level_theme = str(_get_value(map, "gametheme", "entorno")).to_upper()
	if _level_theme in Level.LevelTheme:
		#sub.level_theme = Level.LevelTheme[_level_theme]
		sub.level_theme = Level.LevelTheme.OVERWORLD
	
	sub.night_mode = bool(_get_value(map, "nightmode", "modo_noche"))
	#endregion
	
	print("Sub-Area Metadata DONE")
	
	if meta_only:
		return lvl
	
	#region sub-area terrain
	for i in terrain:
		if i is Dictionary:
			var ground: GroundPart = preload("uid://dpfaa6qawfnk1").instantiate()
			sub.add_part(ground)
			ground.owner = lvl
			ground.level = lvl
			ground.sub_area = sub
			var xx = int(_get_value(i, "xx", "x_pos"))
			var yy = int(_get_value(i, "yy", "y_pos"))
			ground.global_position = Level.snap(Vector2(xx, yy - 432))
			#var idx = _int(_get_value(i, "i", "index"))
			#if idx == null:
				#continue
			#var atlas = SWE_GROUND_FRAME_TABLE.get(idx)
			#ground.atlas(atlas.x, atlas.y)
	# TODO: start height: _get_value(map, "start_y", "ground2")
	#endregion
	
	print("Sub-Area Terrain DONE")
	
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
			var xx = int(_get_value(i, "xx", "x_pos"))
			var yy = int(_get_value(i, "yy", "y_pos"))
			var scn: PackedScene = SWE_OBJECT_TABLE[id]
			var obj = scn.instantiate()
			obj.global_position = Level.snap(Vector2(xx, yy - 432))
			sub.add_part(obj)
			obj.owner = lvl
			obj.level = lvl
			obj.sub_area = sub
	#endregion
	
	print("Sub-Area Objects DONE")
	
	return lvl


func _run() -> void:
	while true:
		_semaphore.wait()
		_queue_mutex.lock()
		var request = _queue.pop_front()
		_queue_mutex.unlock()
		match request.command:
			_Command.EXIT:
				return
			_Command.LOAD:
				var level = _from_swe(request.path, request.meta_only)
				_done.emit.bind(request.id, level).call_deferred()
			_Command.SAVE:
				# TODO: implement level saving
				pass
			_Command.BUILD:
				# TODO: move part building off to thread when switching level to
				# playing
				pass
		


static func _warn_type(key: String, value: Variant) -> void:
	push_warning("%s is invalid value %s (type %s)" %
			[key, value, type_string(typeof(value))])
 

static func _get_value(dict: Dictionary, new: String, old: String) -> Variant:
	return dict.get(new if new in dict else old)
