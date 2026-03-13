class_name PaletteBtn
extends TextureButtonExt


func _pressed() -> void:
	UISoundPlayer.stream = preload("uid://cra6louyi26t1")
	UISoundPlayer.play()
	%RightPanel.status = EditorPanel.Status.HIDDEN
	%LeftPanel.status = EditorPanel.Status.HIDDEN
	%TopPanel.status = EditorPanel.Status.HIDDEN
