class_name ButtonHoverEffect
extends Resource
## Manages the highlighting arrow effect that appears when hovering on buttons.
## 
## This effect draws using the canvas item's draw methods, meaning that
## everything is in the button's local coordinate space.
## [member ButtonHoverEffect.rect] will be determined automatically from the
## [member ButtonHoverEffect.parent]'s [code]size[/code] variable, if it has
## one (e.g. [member Control.size]).
## [br][br]
## An example implementation of this effect in a [TextureButton]:
## [codeblock]
## extends TextureButton
## 
## @onready var effect := ButtonHoverEffect.new(self)
## 
## 
## func _ready() -> void:
##     mouse_entered.connect(effect.start)
##     mouse_exited.connect(effect.stop)
## 
## 
## func _process(_delta: float) -> void:
##     effect.check_redraw()
## 
## 
## func _draw() -> void:
##     effect.draw()
## [/codeblock]
## [ButtonHoverEffect] has to be created once the node is ready, so the size of
## the node would be already determined. Creating it before the node is ready
## will cause the [ButtonHoverEffect]'s hover rectangle to have all its values
## as 0, since the [member Control.size] would be [constant Vector2.ZERO].

## The canvas item to draw the effect to.
var parent: CanvasItem
## The rectangle the arrows will be highlighting.
@export var rect: Rect2
## Whether this effect is enabled.
@export var enabled: bool = false
## The minimum distance the arrows will be away from the button.
@export var arrow_start_pos: float = 3
## The maximum distance the arrows will be away from the button.
@export var arrow_end_pos: float = 9

var _tween: Tween
var _offset: float = arrow_start_pos
var _sprite: Texture2D = load("uid://bxk3nfis807iy")

func _init(
		_parent: CanvasItem,
		_rect := Rect2(Vector2(0, 0), _parent.size) if "size" in _parent else Rect2(),
		_enabled := false,
		_arrow_start_pos := arrow_start_pos,
		_arrow_end_pos := arrow_end_pos
):
	parent = _parent
	rect = _rect
	enabled = _enabled
	arrow_start_pos = _arrow_start_pos
	arrow_end_pos = _arrow_end_pos


## Checks if a redraw should be done, and queues one if it's needed. If you are
## implementing this effect for a button, this should be ran in the
## [method Node._process] virtual method.
func check_redraw() -> void:
	if enabled:
		parent.queue_redraw()


## Starts the effect and its necessary tweens. If the effect isn't started,
## calling [method ButtonHoverEffect.draw] will not draw anything. If you are
## implementing this effect for a button, this should be connected to the
## [signal Control.mouse_entered] signal.
func start() -> void:
	if not GameSettings.show_hover_effect:
		return
	if DisplayServer.is_touchscreen_available():
		return
	_tween = parent.create_tween()
	_tween.tween_property(self, "_offset", arrow_end_pos, 0.417) \
			.from(arrow_start_pos) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "_offset", arrow_start_pos, 0.417) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.set_loops()
	enabled = true


## Stops the effect and its necessary tweens. If the effect isn't stopped,
## the effect's tweens will continue processing in the background. If you are
## implementing this effect for a button, this should be connected to the
## [signal Control.mouse_exited] signal.
func stop() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	enabled = false
	parent.queue_redraw()
	_offset = arrow_start_pos


## Draws the effect using the [member ButtonHoverEffect.parent] property's
## draw methods. This will not draw anything unless the effect has been started
## with [method ButtonHoverEffect.start] and not stopped with
## [method ButtonHoverEffect.stop].
## [br][br]
## [b]Note:[/b] This clears the parent canvas item's set transforms if the
## effect is enabled.
func draw() -> void:
	if not enabled:
		return
	var vec = -Vector2(_offset, _offset)
	parent.draw_set_transform(rect.position)
	parent.draw_texture(_sprite, vec)
	parent.draw_set_transform(Vector2(rect.end.x, rect.position.y),
			0, Vector2(-1, 1))
	parent.draw_texture(_sprite, vec)
	parent.draw_set_transform(Vector2(rect.position.y, rect.end.y),
			0, Vector2(1, -1))
	parent.draw_texture(_sprite, vec)
	parent.draw_set_transform(rect.end, 0, Vector2(-1, -1))
	parent.draw_texture(_sprite, vec)
	parent.draw_set_transform(Vector2(0, 0))
