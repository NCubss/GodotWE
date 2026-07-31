class_name PaletteBtn
extends TextureButton

@onready var _effect := ButtonHoverEffect.new(self)


func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _draw() -> void:
	_effect.draw()


func _pressed() -> void:
	%PaletteSounds.stream = preload("uid://cra6louyi26t1")
	%PaletteSounds.play()
	%RightPanel.status = EditorPanel.Status.HIDDEN
	%LeftPanel.status = EditorPanel.Status.HIDDEN
	%TopPanel.status = EditorPanel.Status.HIDDEN
	%Clapperboard.off_screen = true
	%PaletteMenu.show()


func _mouse_entered() -> void:
	UISoundPlayer.stream = preload("uid://bbc6fa1b5njqq")
	UISoundPlayer.play()
	_effect.start()


func _mouse_exited() -> void:
	_effect.stop()
