extends CanvasLayer

const CURSOR = preload("uid://didh4a8ydo6sc")
const CURSOR_HELD = preload("uid://ucurchi6bbp8")

var sprite := Sprite2D.new()
var down := false:
	set = _set_down


func _ready() -> void:
	layer = 9
	process_mode = Node.PROCESS_MODE_ALWAYS
	down = down
	
	sprite.name = "CursorSprite"
	add_child(sprite)
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_window().mouse_entered.connect(_mouse_entered)
	get_window().mouse_exited.connect(_mouse_exited)
	get_window().focus_entered.connect(_mouse_entered)
	get_window().focus_exited.connect(_mouse_exited)


func _process(_delta: float) -> void:
	sprite.global_position = sprite.get_global_mouse_position()


func _mouse_entered() -> void:
	if get_window().has_focus():
		create_tween().tween_property(sprite, ^"modulate:a", 1.0, 0.1)


func _mouse_exited() -> void:
	create_tween().tween_property(sprite, ^"modulate:a", 0.0, 0.1)


func _set_down(v: bool) -> void:
	down = v
	sprite.texture = CURSOR_HELD if v else CURSOR
