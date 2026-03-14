class_name PartInfo
extends Resource

## Represents the available part categories.
enum Category {
	TERRAIN,
	ITEMS,
	ENEMIES,
	GIZMOS,
}

## The part's name. in its unlocalized form.
@export var name: String
@export var game_style_unique_name: bool
@export var level_theme_unique_name: bool
## The part's 60x60 icon used in the variant window and card.
@export var icon: Texture2D
## The icon's texture filter to draw with. Useful for determining what icons
## should be drawn with.
@export var icon_filter: CanvasItem.TextureFilter
## The category this item falls under.
@export var category: Category
## The path of the scene containing the spawnable part.
@export_file("*.tscn") var scene_path: String
## The size of this part. This must match the part's
## [member TileComponent.size].
@export var size := Vector2i(1, 1)
## Whether this part should be placed multiple times in one mouse press.
@export var multi_place := false

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
			assert(false, "Invalid category %d" % c)
			return Color.GRAY


## Instantiates a new part from the [member scene_path].
func create() -> Part:
	return load(scene_path).instantiate()
