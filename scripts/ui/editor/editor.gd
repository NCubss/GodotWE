class_name Editor
extends Control


func _init():
	theme = ThemeDB.get_project_theme()


## Returns the currently selected [Part] from the card bar on the top panel.
## If no [Part] is selected, [code]null[/code] is returned.
func get_selected_part() -> Part:
	var card = EditorCard.card_group.get_pressed_button() as EditorCard
	if card == null:
		return null
	else:
		return card.part
