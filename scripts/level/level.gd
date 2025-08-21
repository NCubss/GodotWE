class_name Level
extends Node2D
## Represents a level.

enum GameStyle {
	SMB,
	SMB3,
	SMW,
	NSMBU,
}

enum GameTheme {
	OVERWORLD,
	UNDERGROUND,
	UNDERWATER,
	CASTLE,
	SKY,
	AIRSHIP,
	DESERT,
	SNOW,
	MANSION,
	FOREST,
	FALL,
	BEACH,
	MOUNTAIN,
}

## The speed at which the water/lava rises and sinks.
enum WaterSpeed {
	SLOW,
	MEDIUM,
	FAST,
}

## The speed the autoscroll will scroll at.
enum Autoscroll {
	NONE,
	SLOW,
	NORMAL,
	FAST,
}

## Represents a clear condition type.
enum ClearCondition {
	NONE,
	NO_COINS,
	WATER_ONLY,
	DONT_LAND_ON_GROUND,
	NO_DAMAGE,
}

enum Tag {
	NONE,
	STANDARD,
	PUZZLE_SOLVING,
	SPEEDRUN,
	AUTOSCROLL,
	AUTO_MARIO,
	SHORT_AND_SWEET,
	MULTIPLAYER_VERSUS,
	THEMED,
	MUSIC,
	ART,
	TECHNICAL,
	SHOOTER,
	BOSS_BATTLE,
	SINGLEPLAYER,
	LINK
}

@export var level_name: String
@export var author: String
@export var tag_1: Tag = Tag.STANDARD
@export var tag_2: Tag = Tag.NONE
@export_multiline var description := ""
@export var game_style := GameStyle.SMW
@export var time := 430
# probably should make a class for this
@export var clear_condition := ClearCondition.NONE

var _sub_areas = Array[SubArea]


func _init(_level_name: String, _author: String, _game_style := GameStyle.SMW):
	game_style = _game_style
	level_name = _level_name
	author = _author


func _ready() -> void:
	for i in get_children():
		if i is SubArea:
			_sub_areas.append(i)
	assert(not _sub_areas.is_empty(), "Level does not have any sub-areas.")
