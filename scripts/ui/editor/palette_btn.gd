class_name PaletteBtn
extends TextureButton

@onready var _effect := ButtonHoverEffect.new(self,
		Rect2(0, 0, size.x, size.y - 6))


func _ready() -> void:
	mouse_entered.connect(_effect.start)
	mouse_exited.connect(_effect.stop)


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _draw() -> void:
	_effect.draw()


func _pressed() -> void:
	UISoundPlayer.stream = preload("uid://cra6louyi26t1")
	UISoundPlayer.play()
	%RightPanel.status = EditorPanel.Status.HIDDEN
	%LeftPanel.status = EditorPanel.Status.HIDDEN
	%TopPanel.status = EditorPanel.Status.HIDDEN
