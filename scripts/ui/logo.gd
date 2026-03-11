@tool
class_name Logo
extends Control
## Draws the game logo.

static var _is_christmas: bool = Time.get_date_dict_from_system().month == 12


@export var white := true:
	set(value):
		white = value
		queue_redraw()
@export var world_engine := true:
	set(value):
		world_engine = value
		queue_redraw()
		update_minimum_size()

const _SUPER_WHITE = preload("uid://8vb4lqljf8pe")
const _SUPER_CHRISTMAS_WHITE = preload("uid://cstwnone4m3ko")
const _SUPER_BLACK = preload("uid://dcaeq18ofu4gu")
const _SUPER_CHRISTMAS_BLACK = preload("uid://drynii8hafvrl")
const _M_WHITE = preload("uid://6advqv4u43bl")
const _M_BLACK = preload("uid://lrxkrdwj64ev")
const _A_WHITE = preload("uid://htheo8wds0hk")
const _A_BLACK = preload("uid://bj56n00f1wuih")
const _R_WHITE = preload("uid://dxwl5jem3d8sh")
const _R_BLACK = preload("uid://coqaj6sfbsbwl")
const _I_WHITE = preload("uid://bc28e1ek38n6f")
const _I_BLACK = preload("uid://d3eu5ogdnqobn")
const _O_WHITE = preload("uid://sxke6lkwdbh3")
const _O_BLACK = preload("uid://bcoi5ad4r8i6u")
const _K_WHITE = preload("uid://c8y3c16aofccm")
const _K_BLACK = preload("uid://bnlrb708t8vp7")
const _E_WHITE = preload("uid://4yhh82t0ofop")
const _E_BLACK = preload("uid://bx0taogf05fpm")
const _WORLD_ENGINE_WHITE = preload("uid://d6x8usyvvdni")
const _WORLD_ENGINE_BLACK = preload("uid://bl7gsi2cidfvv")


func _get_minimum_size() -> Vector2:
	if world_engine:
		return Vector2(627, 252)
	else:
		return Vector2(627, 186)


func _draw() -> void:
	draw_texture(_get_super(), Vector2(0, 0))
	draw_texture_rect(_get_m(), Rect2(21, 90, 57, 69), false)
	draw_texture_rect(_get_a(), Rect2(90, 90, 45, 69), false)
	draw_texture_rect(_get_r(), Rect2(147, 90, 45, 69), false)
	draw_texture_rect(_get_i(), Rect2(204, 90, 12, 69), false)
	draw_texture_rect(_get_o(), Rect2(228, 90, 63, 69), false)
	draw_texture_rect(_get_m(), Rect2(327, 90, 57, 69), false)
	draw_texture_rect(_get_a(), Rect2(396, 90, 45, 69), false)
	draw_texture_rect(_get_k(), Rect2(453, 90, 45, 69), false)
	draw_texture_rect(_get_e(), Rect2(510, 90, 39, 69), false)
	draw_texture_rect(_get_r(), Rect2(561, 90, 45, 69), false)
	if world_engine:
		draw_texture(_get_world_engine(), Vector2(384, 183))


func _get_super() -> Texture2D:
	if white:
		if _is_christmas:
			return _SUPER_CHRISTMAS_WHITE
		else:
			return _SUPER_WHITE
	else:
		if _is_christmas:
			return _SUPER_CHRISTMAS_BLACK
		else:
			return _SUPER_BLACK


func _get_world_engine() -> Texture2D:
	if white:
		return _WORLD_ENGINE_WHITE
	else:
		return _WORLD_ENGINE_BLACK


func _get_m() -> Texture2D:
	if white:
		return _M_WHITE
	else:
		return _M_BLACK


func _get_a() -> Texture2D:
	if white:
		return _A_WHITE
	else:
		return _A_BLACK


func _get_r() -> Texture2D:
	if white:
		return _R_WHITE
	else:
		return _R_BLACK


func _get_i() -> Texture2D:
	if white:
		return _I_WHITE
	else:
		return _I_BLACK


func _get_o() -> Texture2D:
	if white:
		return _O_WHITE
	else:
		return _O_BLACK


func _get_k() -> Texture2D:
	if white:
		return _K_WHITE
	else:
		return _K_BLACK


func _get_e() -> Texture2D:
	if white:
		return _E_WHITE
	else:
		return _E_BLACK
