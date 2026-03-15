class_name TitleScreen
extends Control


func _ready() -> void:
	%Name.text = Utility.username
	%Version.text = ProjectSettings.get_setting("application/config/version")
