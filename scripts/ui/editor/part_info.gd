class_name PartInfo
extends Resource

## Represents the available part categories.
enum Category {
	TERRAIN,
	ITEMS,
	ENEMIES,
	GIZMOS,
}

## The part's name table, which stores this part's names for each game style.
@export var name_table: Dictionary[Level.GameStyle, String]
## The part's 60x60 icon used in the variant window and card.
@export var icon: Texture2D
## The icon's texture filter to draw with. Useful for determining what icons
## should be drawn with.
@export var icon_filter: CanvasItem.TextureFilter
## The category this item falls under.
@export var category: Category
## The scene containing the spawnable part.
@export var part: PackedScene

## Gets the specified category's ([param c]) color.
static func get_category_color(c: Category) -> Color:
	match c:
		Category.TERRAIN:
			return Color("12d4ed")
		Category.ITEMS:
			return Color("d851e1")
		Category.ENEMIES:
			return Color("6efa20")
		Category.GIZMOS:
			return Color("f2ef08")
		_:
			push_warning("Invalid category", c)
			return Color.GRAY
