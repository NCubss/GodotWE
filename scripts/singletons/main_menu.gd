extends CanvasLayer

enum Status {
	CLOSED,
	OPENING,
	OPEN,
	CLOSING,
}

var menu: ColorRect
var menu_player: AudioStreamPlayer
var status: Status = Status.CLOSED


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100000
	menu = preload("uid://b1fhtapnp8h8j").instantiate()
	menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_child(menu)
	menu_player = menu.get_node("%MenuPlayer")


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("pause"):
			if status == Status.CLOSED:
				open()
			elif status == Status.OPEN:
				close()


func open() -> void:
	if status != Status.CLOSED:
		return
	menu_player.play()
	get_tree().paused = true
	status = Status.OPENING
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(get_viewport(), "global_canvas_transform:origin:x",
			-menu.get_node("%MainMenuUI").size.x, 0.5)
	tween.parallel().tween_property(menu, "color:a", 0.25, 0.5)
	await tween.finished
	status = Status.OPEN


func close() -> void:
	if status != Status.OPEN:
		return
	menu_player.play()
	status = Status.CLOSING
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(get_viewport(), "global_canvas_transform:origin:x", 0,
			0.5)
	tween.parallel().tween_property(menu, "color:a", 0, 0.5)
	await tween.finished
	status = Status.CLOSED
	get_tree().paused = false
