class_name IntroPlayButton
extends IntroButton


func _pressed() -> void:
	super()
	SceneManager.fade_to("uid://h1dvwi2n2ugk", SceneManager.Transition.FADE,
			SceneManager.Transition.CIRCLE)
