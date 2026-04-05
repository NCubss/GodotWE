class_name Credits
extends ColorRect


func _ready() -> void:
	%Text.text %= [
		tr(&"CREDITS_PROGRAMMERS"),
		tr(&"CREDITS_SOUNDS_MUSIC"),
		tr(&"CREDITS_SPRITERS"),
		tr(&"CREDITS_TRANSLATIONS"),
		tr(&"CREDITS_ANIMATION_EFFECTS"),
		tr(&"CREDITS_TYPOGRAPHY"),
		tr(&"CREDITS_ADDITIONAL"),
		tr(&"CREDITS_EK_CONTRIBUTIONS"),
		tr(&"CREDITS_SPECIAL_THANKS"),
		tr(&"CREDITS_POWERED_BY"),
		tr(&"CREDITS_AND_YOU") % Utility.username,
	]
	MusicPlayer.stream = preload("uid://b18iw60y67wvj")
	MusicPlayer.play()
	var tween = create_tween()
	tween.tween_property(%Container, "position:y", -5000,
			MusicPlayer.stream.get_length())
	tween.parallel()
	tween.tween_callback(_close_btn_pressed) \
			.set_delay(MusicPlayer.stream.get_length() - 0.5)


func _close_btn_pressed() -> void:
	SceneManager.fade_to_scene(preload("uid://d11xvcdkd38jq"),
			SceneManager.Transition.FADE,
			SceneManager.Transition.CIRCLE)
