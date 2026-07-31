class_name PopoutBtn
extends TextureButton
## Implements popout control and animation behavior.

## The [EditorPopout] this button opens. 
@export var popout: EditorPopout
## The [Rect2] to use for the hover [member effect]. By default it uses the
## button [member size].
@export var hover_rect := Rect2(Vector2(0, 0), size)
## The [Rect2] used to draw the connection between this button and the popout.
## The rect should be positioned right before any shaped corners while not
## covering up any visuals on the button's sprite.
@export var connect_rect: Rect2
## THe sound this button plays when hovered.
@export var hover_sound := preload("uid://bbc6fa1b5njqq")

## The [ButtonHoverEffect] for this button. You must call [method
## ButtonHoverEffect.draw] yourself.
var effect := ButtonHoverEffect.new(self, hover_rect) 

var _tween: Tween
var _progress := 0.0


func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	popout.status_changed.connect(_popout_status_changed)


func _process(_delta: float) -> void:
	effect.check_redraw()
	if _tween != null and _tween.is_valid():
		queue_redraw()


func _draw() -> void:
	var rect = Rect2(connect_rect)
	rect.size.x *= _progress
	if popout.side == EditorPopout.PopoutDirection.TO_LEFT:
		rect.position.x = connect_rect.end.x - rect.size.x
	draw_rect(rect, Utility.COLOR_DARK)


## Called when the mouse enters the button.
func _mouse_entered() -> void:
	UISoundPlayer.stream = hover_sound
	UISoundPlayer.play()
	effect.start()


## Called when the mouse exits this button.
func _mouse_exited() -> void:
	effect.stop()


func _popout_status_changed(_old_status: EditorPopout.Status) -> void:
	match popout.status:
		EditorPopout.Status.OPENING:
			set_pressed_no_signal(true)
			_tween = create_tween()
			_tween.set_trans(Tween.TRANS_QUAD)
			_tween.set_ease(Tween.EASE_OUT)
			_tween.tween_property(self, "_progress", 1, 0.1)
		EditorPopout.Status.CLOSING:
			set_pressed_no_signal(false)
			_tween.kill()
			_progress = 0


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		mouse_behavior_recursive = MOUSE_BEHAVIOR_ENABLED
		popout.open()
	else:
		popout.close()
		mouse_behavior_recursive = MOUSE_BEHAVIOR_INHERITED
