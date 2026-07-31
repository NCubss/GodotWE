class_name CategoryBtn
extends Button

static var category_btn_group := ButtonGroup.new()

@export var category: PaletteCategory:
	set(v):
		text = tr(v.name)
		get_theme_stylebox(&"normal").modulate_color = v.color
		_text_alpha(1 if button_pressed else 0)
		category = v
		queue_redraw()

@onready var _effect := ButtonHoverEffect.new(self)


func _ready() -> void:
	mouse_entered.connect(_effect.start)
	mouse_exited.connect(_effect.stop)
	button_group = category_btn_group


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _effect != null:
		_effect.rect = Rect2(Vector2(0, 0), size)


func _draw() -> void:
	if category != null:
		draw_texture(category.icon, Vector2(0, 0))
	_effect.draw()


func _toggled(toggled_on: bool) -> void:
	var before_load = false
	if not is_node_ready():
		await ready
		before_load = true
	if %Tabs == null:
		await tree_entered
		before_load = true
	if toggled_on:
		text = tr(category.name)
		if before_load:
			custom_minimum_size.x = 363
			await %Tabs.resized
			%Tabs.position.x = _get_container_x()
		else:
			%PaletteSounds.stream = preload("uid://jklr4ry0ewb")
			%PaletteSounds.play()
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_QUAD)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "custom_minimum_size:x", 363, 0.25)
			tween.parallel()
			tween.tween_property(%Tabs, "position:x", _get_container_x(), 0.25)
			tween.parallel()
			tween.tween_method(_text_alpha, _get_alpha(), 1.0, 0.125) \
					.set_delay(0.125) \
					.set_ease(Tween.EASE_IN_OUT)
		%PaletteRing.category = category
	else:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "custom_minimum_size:x", 66, 0.25)
		tween.parallel()
		tween.tween_method(_text_alpha, _get_alpha(), 0.0, 0.1875) \
				.set_ease(Tween.EASE_IN_OUT)


func _get_container_x() -> float:
	return (%PaletteMenu.size.x / 2) - (get_index() * 84 + 181.5)


func _text_alpha(a: float) -> void:
	var color = Color("5d1c1c")
	color.a = a
	add_theme_color_override(&"font_color", color)
	add_theme_color_override(&"font_focus_color", color)
	add_theme_color_override(&"font_pressed_color", color)
	add_theme_color_override(&"font_hover_color", color)
	add_theme_color_override(&"font_hover_pressed_color", color)
	add_theme_color_override(&"font_disabled_color", color)


func _get_alpha() -> float:
	return get_theme_color(&"font_color").a
