class_name PaletteBtn
extends TextureButtonExt


func _pressed() -> void:
	UISoundPlayer.stream = preload("uid://cra6louyi26t1")
	UISoundPlayer.play()
	%RightPanel.extended = false
	%LeftPanel.extended = false
	%TopPanel.extended = false
	%RightPanel.locked = true
	%LeftPanel.locked = true
	%TopPanel.locked = true
