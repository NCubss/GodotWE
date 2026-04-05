class_name PaletteNavigationBtn
extends TextureButton


func _pressed() -> void:
	# go backwards
	if flip_h:
		# go a category backwards
		if %PaletteRing.page_index == 0:
			_move_category(-1)
		# go a page backwards
		else:
			%PaletteSounds.stream = preload("uid://danwpgbsl7wsb")
			%PaletteSounds.play()
		%PaletteRing.page_index = posmod(%PaletteRing.page_index - 1,
				%PaletteRing.category.pages.size())
	# go forwards
	else:
		# go a category backwards
		if %PaletteRing.page_index == %PaletteRing.category.pages.size() - 1:
			_move_category(1)
		# go a page backwards
		else:
			%PaletteSounds.stream = preload("uid://doegrnl8yjdr0")
			%PaletteSounds.play()
		%PaletteRing.page_index = posmod(%PaletteRing.page_index + 1,
				%PaletteRing.category.pages.size())


func _move_category(step: int) -> void:
	var current = CategoryBtn.category_btn_group.get_pressed_button()
	var idx = current.get_index()
	var next: CategoryBtn = %Tabs.get_child(
			posmod(idx + step, %Tabs.get_child_count()))
	next.button_pressed = true
