@tool
extends EditorPlugin

const OUTPUT_TEXT = "Output preview:"
const OUTPUT_LOAD_FAIL = "Failed to load sheet"
const OUTPUT_SAVE_ERROR = "Error saving icon: %s"
const OUTPUT_SAVED = "Icon saved!"
const TOOL_TEXT = "Generate Terrain Icon..."
const ERROR_COLOR = Color.INDIAN_RED
const SUCCESS_COLOR = Color.LIME_GREEN

var dialog: AcceptDialog = load("uid://drd2p1iat7a70").instantiate()
var image: Image:
	set = _set_image


func _enter_tree() -> void:
	add_child(dialog)
	dialog.get_node(^"%SheetPathOpen").pressed.connect(
			_open_file_dialog.bind(^"%SheetPathInput", "Sheet image", false))
	dialog.get_node(^"%ResultPathOpen").pressed.connect(
			_open_file_dialog.bind(^"%ResultPathInput", "Icon image", true))
	dialog.get_node(^"%SheetPathInput").text_changed.connect(
			func(_text): _draw_image())
	dialog.get_node(^"%Gridlines").toggled.connect(_gridlines)
	dialog.confirmed.connect(_save_image)
	
	add_tool_menu_item(TOOL_TEXT, dialog.popup_centered_clamped)


func _exit_tree() -> void:
	remove_child(dialog)
	remove_tool_menu_item(TOOL_TEXT)


func _open_file_dialog(path: NodePath, description: String, save: bool) -> void:
	var input: LineEdit = dialog.get_node(path)
	
	var file_dialog = EditorFileDialog.new()
	file_dialog.add_filter("*.png", description, "image/png")
	if save:
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	else:
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	
	dialog.add_child(file_dialog)
	file_dialog.popup_file_dialog()
	
	input.text = await file_dialog.file_selected
	input.text_changed.emit(input.text)
	file_dialog.queue_free()


func _draw_image() -> void:
	var result = Image.create_empty(60, 60, false, Image.FORMAT_RGBA8)
	var sheet = Image.load_from_file(dialog.get_node(^"%SheetPathInput").text)
	if sheet == null:
		_set_output_text(OUTPUT_LOAD_FAIL, ERROR_COLOR)
		return
	
	sheet.resize(sheet.get_size().x * 2, sheet.get_size().y * 2,
			Image.INTERPOLATE_NEAREST)
	
	for i in range(0, 33, 32):
		result.blit_rect(sheet, Rect2i(32, i, 32, 32), Vector2i(14, 14 + i))
		result.blit_rect(sheet, Rect2i(64, i, 32, 32), Vector2i(-18, 14 + i))
		result.blit_rect(sheet, Rect2i(96, i, 32, 32), Vector2i(46, 14 + i))
	
	_set_output_text(OUTPUT_TEXT)
	
	image = result


func _set_output_text(text: String, color := Color.WHITE) -> void:
	var label = dialog.get_node(^"%Label")
	label.text = text
	label.label_settings.font_color = color


func _save_image() -> void:
	if image == null:
		_draw_image()
		if image == null:
			return
	var error = image.save_png(dialog.get_node(^"%ResultPathInput").text)
	if error != OK:
		_set_output_text(OUTPUT_SAVE_ERROR % error_string(error))
		return
	EditorInterface.get_resource_filesystem().scan()
	_set_output_text(OUTPUT_SAVED, SUCCESS_COLOR)


func _gridlines(on: bool) -> void:
	dialog.get_node(^"%Preview").draw_grid = on


func _set_image(v: Image) -> void:
	image = v
	dialog.get_node(^"%Preview").texture = ImageTexture.create_from_image(v)
