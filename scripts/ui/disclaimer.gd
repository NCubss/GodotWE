extends Control


func _ready() -> void:
	UISoundPlayer.stream = load("uid://p6tcioq6lep1")
	UISoundPlayer.play()
	await %IntroTimer.timeout
	SceneManager.fade_to("uid://dtq1i14h6pmvn")
