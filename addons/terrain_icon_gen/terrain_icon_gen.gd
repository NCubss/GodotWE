@tool
extends EditorPlugin

var dialog: AcceptDialog = load("uid://drd2p1iat7a70").instantiate()
var tree: SceneTree = Engine.get_main_loop()


func _enable_plugin() -> void:
	tree.root.add_child(dialog)
	dialog.get_node(^"%SheetPathOpen").pressed.connect(func():
		var file_dialog = EditorFileDialog.new()
		dialog.add_child(file_dialog)
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialog.popup_file_dialog()
		dialog.get_node(^"%SheetPathInput").text = await file_dialog.file_selected
		file_dialog.queue_free()
	)
	dialog.get_node(^"%ResultPathOpen").pressed.connect(func():
		var file_dialog = EditorFileDialog.new()
		dialog.add_child(file_dialog)
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.popup_file_dialog()
		dialog.get_node(^"%ResultPathInput").text = await file_dialog.file_selected
		file_dialog.queue_free()
	)
	add_tool_menu_item("Generate Terrain Icon...", dialog.popup_centered_clamped)
	dialog.confirmed.connect(func():
		var result = Image.create_empty(60, 60, false, Image.FORMAT_RGBA8)
		var sheet: Image = Image.create_empty(1, 1, false, Image.FORMAT_RGBA8)
		sheet.copy_from(load(dialog.get_node(^"%SheetPathInput").text).get_image())
		sheet.resize(sheet.get_size().x * 2, sheet.get_size().y * 2, Image.INTERPOLATE_NEAREST)
		result.blit_rect(sheet, Rect2i(32, 0, 32, 32), Vector2i(14, 14))
		result.blit_rect(sheet, Rect2i(64, 0, 32, 32), Vector2i(-18, 14))
		result.blit_rect(sheet, Rect2i(96, 0, 32, 32), Vector2i(46, 14))
		result.blit_rect(sheet, Rect2i(32, 32, 32, 32), Vector2i(14, 46))
		result.blit_rect(sheet, Rect2i(64, 32, 32, 32), Vector2i(-18, 46))
		result.blit_rect(sheet, Rect2i(96, 32, 32, 32), Vector2i(46, 46))
		result.save_png(dialog.get_node(^"%ResultPathInput").text)
		EditorInterface.get_resource_filesystem().scan()
	)


func _disable_plugin() -> void:
	tree.root.remove_child(dialog)
	remove_tool_menu_item("Generate Terrain Icon...")
