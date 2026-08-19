class_name EditorPanelHandle
extends TextureButton

const TOGGLE_PANEL = preload("uid://wtbs8v38vb0l")

var panel: EditorPanel


func _enter_tree() -> void:
	panel = get_parent() as EditorPanel


func _pressed() -> void:
	
	if can_use():
		match panel.status:
			EditorPanel.Status.OPEN:
				panel.status = EditorPanel.Status.CLOSED
			EditorPanel.Status.CLOSED:
				panel.status = EditorPanel.Status.OPEN
	
	UISoundPlayer.stream = TOGGLE_PANEL
	UISoundPlayer.play()


func can_use() -> bool:
	return panel.status != EditorPanel.Status.HIDDEN \
			and %Editor.erasing == Editor.EraseMode.NONE \
			and %Editor.part_interact
