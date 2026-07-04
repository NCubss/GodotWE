class_name Disclaimer
extends Control
## The disclaimer scene.


func _ready() -> void:
	UISoundPlayer.stream = preload("uid://p6tcioq6lep1")
	UISoundPlayer.play()
	await %IntroTimer.timeout
	SceneManager.fade_to_scene(preload("uid://dtq1i14h6pmvn"))
