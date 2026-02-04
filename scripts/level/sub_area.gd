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

## The background node.
var background: Node
## The foreground node, which stores all tiles and entities.
var foreground: Node
## The editor foreground node, which stores all parts. Only available if this
## level is being edited (i.e. [member Level.editor] is not [code]null[/code]).
var editor_foreground: Node
## The sub-area's parent level.
var level: Level


## Called by the [Level] to make sure this [SubArea] is ready to enter (i.e.,
## creating the background).
func load(_level: Level) -> void:
	level = _level
	var background_scene = load(GameConstants.BACKGROUNDS \
			[_level.game_style][level_theme][night_mode])
	background = background_scene.instantiate()
	add_child(background)
	foreground = $Foreground
	for i in foreground.get_children():
		i = i as Entity
		if i == null:
			continue
		i.level = level
		i.sub_area = self
	if Utility.id("editor") != null:
		editor_foreground = Node.new()
		editor_foreground.name = "EditorForeground"
		add_child(editor_foreground)


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
