class_name PaletteCategory
extends Resource

## The color of this category.
@export var color: Color
## The translation key for the name of this category.
@export var name: StringName
## The icon for this category.
@export var icon: Texture2D
## This category's [PalettePage]s. Does not support null pages. For empty pages,
## create a page with all null items.
@export var pages: Array[PalettePage]
