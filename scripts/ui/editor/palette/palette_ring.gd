class_name PaletteRing
extends TextureRect

const SOUNDS = [
	preload("uid://dc150i2eolkhd"),
	preload("uid://dj5bkt4ecjt1b"),
	preload("uid://bkry1i6h4dr6t"),
	preload("uid://b66qid62rh8dq"),
	preload("uid://crl2l1tq8vlel"),
	preload("uid://drfspga3d1pod"),
	preload("uid://d01axu580ohxy"),
	preload("uid://3k872tf488mw"),
	preload("uid://be48q5n1a5xem"),
	preload("uid://c5kof8soyg2pd"),
]

## The currently selected category.
@export var category: PaletteCategory:
	set = _set_category
## The currently open category page index.
@export var page_index: int:
	set = _set_page_index

## The currently hovered sector.
var selected: int:
	set = _set_selected
## The color of the palette ring.
var color: Color:
	get = _get_color,
	set = _set_color

var _mouse_in_window := true


func _process(_delta: float) -> void:
	# process hovered sector
	# is the mouse in the sectors?
	var in_ring = Geometry2D.is_point_in_circle(get_local_mouse_position(),
			Vector2(204, 204), 204)
	var in_center = Geometry2D.is_point_in_circle(
			get_local_mouse_position(), Vector2(204, 204), 81)
	if get_page() != null and _mouse_in_window and is_visible_in_tree() \
			and in_ring and not in_center:
		# algorithm to find hovered sector
		# starting processing direction
		var direction = 0
		# current sector edge
		var sector = 0
		var mouse = get_local_mouse_position() - Vector2(204, 204)
		mouse.y = -mouse.y
		while true:
			# sector edge angle
			var angle = TAU / get_page().items.size() * (sector - 0.5) + (PI / 2)
			var normal = Vector2(sin(angle), cos(angle))
			# negative if left, positive if right
			var s = normal.dot(mouse)
			if direction == 0:
				direction = int(signf(s))
			elif direction != signf(s):
				if direction == 1:
					sector -= 1
				break
			# move to next sector edge
			sector = posmod(sector + direction, get_page().items.size())
		selected = sector
	else:
		selected = -1


func _gui_input(event: InputEvent) -> void:
	# sector pressed behavior
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed \
				and selected >= 0:
			var card: EditorCard
			# find an existing card with this part
			for i: EditorCard in %Cards.get_children():
				if i.part == get_page().items[selected].part:
					card = i
			# otherwise, add a new one
			if card == null:
				%Cards.remove_child(%Cards.get_child(0))
				card = preload("uid://b16vc6ry30e6p").instantiate()
				%Cards.add_child(card)
				card.part = get_page().items[selected].part
			# trigger the sound
			card.button_pressed = false
			card.button_pressed = true
			%TopPanel.status = EditorPanel.Status.OPEN
			%LeftPanel.status = EditorPanel.Status.OPEN
			%RightPanel.status = EditorPanel.Status.OPEN
			%Clapperboard.off_screen = false
			%PaletteMenu.hide()


func _notification(what: int) -> void:
	# don't check for hovered sectors while the mouse is not in the window
	match what:
		NOTIFICATION_WM_MOUSE_ENTER:
			_mouse_in_window = true
		NOTIFICATION_WM_MOUSE_EXIT:
			_mouse_in_window = false
		NOTIFICATION_VISIBILITY_CHANGED:
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_QUAD)
			if is_visible_in_tree():
				tween.tween_property(self, "scale", Vector2(1, 1), 0.25) \
						.from(Vector2(0, 0)) \
						.set_ease(Tween.EASE_OUT)
			else:
				tween.tween_property(self, "scale", Vector2(0, 0), 0.25) \
						.set_ease(Tween.EASE_IN)


func get_page() -> PalettePage:
	return category.pages[page_index]


func _set_category(v: PaletteCategory) -> void:
	if v == null:
		return
	color = v.color
	category = v
	page_index = 0


func _set_page_index(v: int) -> void:
	if category == null:
		return
	# preparation and cleanup
	var page = category.pages[v]
	if not is_node_ready():
		await ready
	if %Editor.level == null:
		await %Editor.loaded
	for i in %Icons.get_children():
		if i != %PaletteCenter:
			i.queue_free()
	# set ring textures
	match page.items.size():
		7:
			texture = preload("uid://bjkjvbo5dxhvr")
			%Sector.texture = preload("uid://ckdt2mc8m05xn")
		8:
			texture = preload("uid://b3gv0ahuwc2i")
			%Sector.texture = preload("uid://b34qwm4hjf88r")
		10:
			texture = preload("uid://y12fpgvjyfv5")
			%Sector.texture = preload("uid://y1u6304a0jj3")
	# set the center icon
	if page.items[0] == null:
		%CenterIcon.texture = null
	else:
		%CenterIcon.texture = page.items[0].part.get_part_icon(
				%Editor.level.current_sub_area)
		%CenterIcon.texture_filter = page.items[0].part \
				.get_part_icon_filter(%Editor.level.current_sub_area)
	# add sector icons
	for i in page.items.size():
		if page.items[i] == null:
			continue
		var icon = _create_icon(page.items[i].part)
		var angle = TAU / page.items.size() * i
		icon.position = Vector2(sin(angle), -cos(angle)) * 147 \
				+ Vector2(204, 204) - Vector2(33, 33)
		if page.items[i].disabled:
			icon.modulate = Color("a5a5a5")
		%Icons.add_child(icon)
	# fade in
	var tween = create_tween()
	tween.tween_property(%Icons, "modulate:a", 1.0, 0.25) \
			.from(0.0) \
			.set_trans(Tween.TRANS_QUAD) \
			.set_ease(Tween.EASE_OUT)
	page_index = v


func _set_selected(v: int) -> void:
	var page = get_page()
	if page.items[v] == null or page.items[v].disabled:
		v = -1
	if v != selected:
		%Sector.visible = v >= 0
		if page != null:
			%Sector.rotation = TAU / page.items.size() * v
		if %Sector.visible:
			UISoundPlayer.stream = SOUNDS.get(v)
			if UISoundPlayer.stream != null:
				UISoundPlayer.play()
			if %Editor.level == null:
				await %Editor.loaded
			%CenterIcon.texture = page.items[v].part.get_part_icon(
					%Editor.level.current_sub_area)
			%CenterIcon.texture_filter = page.items[v].part \
					.get_part_icon_filter(%Editor.level.current_sub_area)
	selected = v


func _get_color() -> Color:
	return material.get_shader_parameter(&"color")


func _set_color(v: Color) -> void:
	var tween = create_tween()
	tween.tween_method(func(c): material.set_shader_parameter(&"color", c),
			material.get_shader_parameter(&"color"), v, 0.25)


# create a sector icon for a part
func _create_icon(part: Script) -> TextureRect:
	var background = TextureRect.new()
	background.texture = preload("uid://bgcosxahmopj8")
	var cutout = TextureRect.new()
	cutout.clip_children = CLIP_CHILDREN_ONLY
	cutout.texture = preload("uid://b3tx16rivyjy4")
	var icon = TextureRect.new()
	icon.texture = part.get_part_icon(%Editor.level.current_sub_area)
	icon.texture_filter = part.get_part_icon_filter(
			%Editor.level.current_sub_area)
	icon.set_anchors_and_offsets_preset(PRESET_CENTER)
	cutout.add_child(icon)
	background.add_child(cutout)
	return background


func _close_btn_pressed() -> void:
	%PaletteMenu.hide()
	%PaletteSounds.stream = preload("uid://dy8hcmykup336")
	%PaletteSounds.play()
	%TopPanel.status = EditorPanel.Status.OPEN
	%LeftPanel.status = EditorPanel.Status.OPEN
	%RightPanel.status = EditorPanel.Status.OPEN
	%Clapperboard.off_screen = false
