class_name TitleScreen
extends Control


func _ready() -> void:
	%Name.text = GameSettings.username
	%Version.text = ProjectSettings.get_setting("application/config/version")
