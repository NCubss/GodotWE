extends Node
## Manages the game's settings.

## The currently configured username of the player.
var username: String
## Whether to show button hover animations (see [ButtonHoverEffect]).
var show_hover_effect: bool

var _flags: Array[StringName]

## The game's config file path.
const GAME_CONFIG_PATH = "user://SMMWE.cfg"


func _init() -> void:
	var file = FileAccess.open(GAME_CONFIG_PATH, FileAccess.ModeFlags.READ)
	# try again if opening the file failed
	if FileAccess.get_open_error() != OK:
		reset_config()
		_init()
		return
	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	file.close()
	if json.data is not Dictionary:
		reset_config()
		_init()
	if not json.data.has_all(["username", "show_hover_effect"]):
		reset_config()
		_init()
	if err == OK:
		if _exists(json.data, "username"):
			username = json.data["username"]
		else:
			return
		if _exists(json.data, "show_hover_effect"):
			show_hover_effect = json.data["show_hover_effect"]
		else:
			return
	else:
		reset_config()
		_init()

## Resets the config file.
func reset_config() -> void:
	var file = FileAccess.open(GAME_CONFIG_PATH, FileAccess.ModeFlags.WRITE)
	file.store_string(JSON.stringify({
		"username": "",
		"show_hover_effect": true
	}, "    "))
	file.close()


func _exists(
		dict: Dictionary, key: Variant
) -> bool:
	if key not in dict:
		reset_config()
		_init()
	return key in dict


func flag_exists(flag: StringName) -> bool:
	return flag in _flags
