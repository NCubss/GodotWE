class_name IntroLinkButton
extends TextureButton
## Represents the links on the post-intro page.

## The link to open once clicked on.
@export var link: String

@onready var _effect := ButtonHoverEffect.new(self)


func _ready() -> void:
	action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	mouse_entered.connect(_entered)
	mouse_entered.connect(_effect.start)
	mouse_exited.connect(_effect.stop)


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _draw() -> void:
	_effect.draw()


func _pressed() -> void:
	if link != "":
		OS.shell_open(link)
		

func _entered() -> void:
	if not DisplayServer.is_touchscreen_available():
		UISoundPlayer.stream = load("uid://dn2weik3slobr")
		UISoundPlayer.play()
