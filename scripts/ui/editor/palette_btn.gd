class_name PaletteBtn
extends TextureButtonExt


func _pressed() -> void:
	UISoundPlayer.stream = preload("res://audio/ui/editor/palette_open.ogg")
	UISoundPlayer.play()
	%RightPanel.extended = false
	%LeftPanel.extended = false
	%TopPanel.extended = false
	%RightPanel.locked = true
	%LeftPanel.locked = true
	%TopPanel.locked = true
