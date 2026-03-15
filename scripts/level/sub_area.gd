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

var editor_foreground: Node
## The sub-area's parent [Level].
var level: Level
## Whether this sub-area has been loaded (see [method load]).
var is_loaded := false


## Called by the [Level] to make sure this [SubArea] is ready to enter (i.e.,
## creating the background).
func load() -> void:
	level.playing.connect(_play)
	level.editing.connect(_edit)
	var background_scene = load(GameConstants.BACKGROUNDS \
			[level.game_style][level_theme][night_mode])
	background = background_scene.instantiate()
	add_child(background)
	for i: Part in %Parts.get_children():
		if i is not Part:
			var cls: Script = i.get_script()
			push_warning("Found non-Part in Parts (class name '%s')" %
					cls.get_global_name())
			continue
		i.sub_area = self
		i.level = level
		i.load()
	match level.status:
		Level.Status.PLAYING:
			_play()
		Level.Status.EDITING:
			_edit()


func get_background() -> Node2D:
	return %Background


## Returns the foreground node, which stores all tiles and entities. Note that
## you shouldn't fill this out yourself, as [Part]s automatically generate
## content to put here (see [method get_parts]).
func get_foreground() -> Node2D:
	return %Foreground


## Returns the node which contains all [Part]s, which generate the tiles and
## entities in the foreground node (see [method get_foreground]).
func get_parts() -> Node2D:
	return %Parts


## Freezes this sub-area. All entities will stop processing and the sub-area
## will be invisible.
func freeze() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()


func unfreeze() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	show()


## Adds a node to this sub-area's foreground and sets metadata
## ([code]sub_area[/code] to this sub-area, [code]level[/code] to this
## sub-area's associated [member level]). Note that this mustn't be used for
## [Part]s, as they have their own [member parts] container node.
func add(node: Node) -> void:
	node.set_meta(&"sub_area", self)
	node.set_meta(&"level", level)
	%Foreground.add_child(node)


func add_part(part: Part) -> void:
	part.sub_area = self
	part.level = level
	%Parts.add_child(part)


func _play() -> void:
	for i: Part in %Parts.get_children():
		if i is not Part:
			continue
		i.build()
	%Parts.hide()


func _edit() -> void:
	for i in %Foreground.get_children():
		i.queue_free()
	%Parts.show()
