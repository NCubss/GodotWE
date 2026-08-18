class_name PopoutOkBtn
extends Button

const HOVER = preload("uid://bbc6fa1b5njqq")

@onready var effect := ButtonHoverEffect.new(self)


func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func _process(_delta: float) -> void:
	effect.check_redraw()


func _draw() -> void:
	effect.draw()


func _pressed() -> void:
	var popout = get_parent() as EditorPopout
	popout.close()


func _mouse_entered() -> void:
	UISoundPlayer.stream = HOVER
	UISoundPlayer.play()
	effect.start()


func _mouse_exited() -> void:
	effect.stop()
