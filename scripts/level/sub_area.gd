class_name SubArea
extends Node2D
## Represents a separated world in a level.

## The level theme this sub-area uses.
@export var level_theme := Level.LevelTheme.OVERWORLD
## Whether this sub-area is in night mode.
@export var night_mode := false
## The water speed of this sub-area. Only applies if this level theme supports
## water.
@export var water_speed := Level.WaterSpeed.SLOW
@export var min_water_height := 1
@export var max_water_height := 1
@export var meteorites := false
@export var autoscroll := Level.Autoscroll.NONE

## The sub-area's parent level.
var level: Level


## Called by the [Level] to make sure this [SubArea] is ready to enter (i.e.,
## creating the background).
func load(_level: Level) -> void:
	level = _level
	if not has_node("Background"):
		var scn = load(GameConstants.BACKGROUNDS \
				[level.game_style][level_theme][night_mode]) as PackedScene
		if scn != null:
			var bg = scn.instantiate()
			bg.name = "Background"
			add_child(bg)
		else:
			push_error("Couldn't load background")
	if not has_node("Shadows"):
		var shadows = CanvasGroup.new()
		shadows.name = "Shadows"
		shadows.self_modulate = Color(0, 0, 0, 0.3)
		shadows.z_index = GameConstants.Layers.Z_SHADOWS
		shadows.z_as_relative = false
		shadows.process_mode = Node.PROCESS_MODE_ALWAYS
		shadows.add_to_group("shadows")
		add_child(shadows)
	if not has_node("Foreground"):
		var foreground = Node.new()
		add_child(foreground)
	if has_node("Foreground") and not has_node("Map"):
		var map = Map.new()
		map.name = "Map"
		map.add_to_group("map")
		add_child(map)


## Freezes this sub-area. All entities will stop processing and the sub-area
## will be invisible.
func freeze() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()


func unfreeze() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	show()


func spawn(entity: Entity, pos: Vector2) -> void:
	$Foreground.add_child(entity)
	entity.global_position = pos
