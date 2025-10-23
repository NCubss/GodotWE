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

var _super_white = load("uid://8vb4lqljf8pe")
var _super_christmas_white = load("uid://cstwnone4m3ko")
var _super_black = load("uid://dcaeq18ofu4gu")
var _super_christmas_black = load("uid://drynii8hafvrl")
var _m_white = load("uid://6advqv4u43bl")
var _m_black = load("uid://lrxkrdwj64ev")
var _a_white = load("uid://htheo8wds0hk")
var _a_black = load("uid://bj56n00f1wuih")
var _r_white = load("uid://dxwl5jem3d8sh")
var _r_black = load("uid://coqaj6sfbsbwl")
var _i_white = load("uid://bc28e1ek38n6f")
var _i_black = load("uid://d3eu5ogdnqobn")
var _o_white = load("uid://sxke6lkwdbh3")
var _o_black = load("uid://bcoi5ad4r8i6u")
var _k_white = load("uid://c8y3c16aofccm")
var _k_black = load("uid://bnlrb708t8vp7")
var _e_white = load("uid://4yhh82t0ofop")
var _e_black = load("uid://bx0taogf05fpm")
var _world_engine_white = load("uid://d6x8usyvvdni")
var _world_engine_black = load("uid://bl7gsi2cidfvv")


func _get_minimum_size() -> Vector2:
	if world_engine:
		return Vector2(627, 252)
	else:
		return Vector2(627, 186)


func _draw() -> void:
	#draw_texture(SUPER_BLACK, Vector2(0, 0))
	draw_texture_rect(_get_super(), Rect2(0, 0, 219, 78), false)
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
		draw_texture_rect(_get_world_engine(), Rect2(384, 183, 222, 42), false)


func _get_super() -> Texture2D:
	if white:
		if _is_christmas:
			return _super_christmas_white
		else:
			return _super_white
	else:
		if _is_christmas:
			return _super_christmas_black
		else:
			return _super_black


func _get_world_engine() -> Texture2D:
	if white:
		return _world_engine_white
	else:
		return _world_engine_black


func _get_m() -> Texture2D:
	if white:
		return _m_white
	else:
		return _m_black


func _get_a() -> Texture2D:
	if white:
		return _a_white
	else:
		return _a_black


func _get_r() -> Texture2D:
	if white:
		return _r_white
	else:
		return _r_black


func _get_i() -> Texture2D:
	if white:
		return _i_white
	else:
		return _i_black


func _get_o() -> Texture2D:
	if white:
		return _o_white
	else:
		return _o_black


func _get_k() -> Texture2D:
	if white:
		return _k_white
	else:
		return _k_black


func _get_e() -> Texture2D:
	if white:
		return _e_white
	else:
		return _e_black
