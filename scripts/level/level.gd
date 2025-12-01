class_name Level
extends Node2D
## Represents a level.

## Represents a game style. Applies across the entire level.
enum GameStyle {
	## The "Super Mario Bros." game style.
	SMB,
	## The "Super Mario Bros. 3" game style.
	SMB3,
	## The "Super Mario World" game style.
	SMW,
	## The "New Super Mario Bros. U" game style.
	NSMBU,
}

## Represents a level theme. Applies only in sub-areas (see [member
## SubArea.level_theme]).
enum LevelTheme {
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

## Represents a level tag.
enum Tag {
	## No tag.
	NONE,
	## "Standard" tag.
	STANDARD,
	## "Puzzle-solving" tag.
	PUZZLE_SOLVING,
	## "Speedrun" tag.
	SPEEDRUN,
	## "Autoscroll" tag.
	AUTOSCROLL,
	## "Auto-Mario" tag.
	AUTO_MARIO,
	## "Short and Sweet" tag.
	SHORT_AND_SWEET,
	## "Multiplayer Versus" tag.
	MULTIPLAYER_VERSUS,
	## "Themed" tag.
	THEMED,
	## "Music" tag.
	MUSIC,
	## "Art" tag.
	ART,
	## "Technical" tag.
	TECHNICAL,
	## "Shooter" tag.
	SHOOTER,
	## "Boss battle" tag.
	BOSS_BATTLE,
	## "Single player" tag.
	SINGLEPLAYER,
	## "Link" tag.
	LINK
}

## The name of the level.
@export var level_name: String
## The level author's username. This is used to determine if the player can edit
## this level.
@export var author: String
## The first tag of the level.
@export var tag_1: Tag = Tag.STANDARD
## The second tag of the level.
@export var tag_2: Tag = Tag.NONE
## The description of the level, with a maximum of 92 characters in-game.
@export_multiline var description := ""
## The game style of the level. See [member SubArea.game_theme] for the game
## theme.
@export var game_style := GameStyle.SMW
@export var time := 430
# probably should make a class for this
@export var clear_condition := ClearCondition.NONE

## The level's automatically assigned sub-areas.
var sub_areas: Array[SubArea] = []
## The current [SubArea], that is, the [SubArea] in which entities are active
## and the player is in.
var current_sub_area: SubArea

func _init(_level_name := "", _author := "", _game_style := GameStyle.SMW):
	game_style = _game_style
	level_name = _level_name
	author = _author


func _ready() -> void:
	for i in get_children():
		if i is SubArea:
			sub_areas.append(i)
			i.load(self)
	assert(not sub_areas.is_empty(), "Level does not have any sub-areas.")
	current_sub_area = sub_areas[0]
	var player: Player = load("uid://b2cwk2viytb57").instantiate()
	
	current_sub_area.spawn(player, Vector2(64, -32))
	add_child(PlayerCamera.new())
