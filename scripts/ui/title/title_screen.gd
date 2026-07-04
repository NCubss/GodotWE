class_name TitleScreen
extends Control


func _ready() -> void:
	%Name.text = Utility.username
	%Version.text = ProjectSettings.get_setting("application/config/version")
	var time = Time.get_date_dict_from_system()
	if time.month == Time.MONTH_DECEMBER:
		%Super.texture = preload("uid://drynii8hafvrl")
