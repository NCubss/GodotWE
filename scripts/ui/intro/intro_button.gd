extends TextureButton

@export var link: String


func _init() -> void:
	if not DisplayServer.is_touchscreen_available():
		mouse_entered.connect(_enter)


func _enter() -> void:
	UISoundPlayer.stream = load("uid://cokrnddb1tf64")
	UISoundPlayer.play()


func _pressed() -> void:
	if link != "":
		UISoundPlayer.stream = load("uid://ciwuj88wqvuqq")
		UISoundPlayer.play()
		OS.shell_open(link)
