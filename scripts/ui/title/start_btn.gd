class_name TitleStartBtn
extends TextureButton


func _pressed() -> void:
	disabled = true
	UISoundPlayer.stream = preload("uid://bytaafvjs4boj")
	UISoundPlayer.play()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 5/36.0)
	tween.tween_property(self, "visible", false, 0)
	tween.tween_property(%Clapperboards, "visible", true, 0)
	tween.tween_property(%Clapperboards, "modulate:a", 1, 5/36.0)
