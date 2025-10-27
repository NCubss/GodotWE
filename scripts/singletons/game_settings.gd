extends Node
## Manages the game's settings.

var username: String

static var _flags: Array[StringName]
static var _cfg: Dictionary[StringName, Variant]



static func _static_init() -> void:
	var file = FileAccess.open(GameConstants.GAME_CONFIG_PATH, \
			FileAccess.ModeFlags.READ)
	# try again if opening the file failed
	if FileAccess.get_open_error() != OK:
		reset_config()
		_static_init()
		return
	var json = JSON.new()
	var err = json.parse(file.get_as_text(true))
	if json.data is not Dictionary:
		pass
	if err == OK:
		_cfg = json.data
	else:
		reset_config()

## Resets the config file.
static func reset_config() -> void:
	var file = FileAccess.open(GameConstants.GAME_CONFIG_PATH, \
			FileAccess.ModeFlags.WRITE)


func flag_exists(flag: StringName) -> bool:
	return flag in _flags
