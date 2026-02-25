class_name Level
extends Node2D
## Represents a level.

## Emitted when the level timer ends.
signal times_up

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

const GRID_SIZE = Vector2(16, 16)

## The [Editor] this level is associated with. Also used for checking if this
## level is being edited.
@onready var editor: Editor = Utility.id("editor")

## The name of the level.
@export var level_name: String
## The level author's username. This is used to determine if the player can edit
## this level.
@export var author: String
## The first tag of the level.
@export var tag_1: Tag = Tag.STANDARD
## The second tag of the level.
@export var tag_2: Tag = Tag.NONE
## The description of the level, with a maximum of 92 characters. Attempting to
## set a string of higher length will cut it to the first 92 characters.
@export_multiline var description := "":
	set(value):
		description = value.substr(0, 92)
## The game style of the level. See [member SubArea.game_theme] for the game
## theme.
@export var game_style := GameStyle.SMW
## The level's timer, in seconds. The player is forcibly killed once it arrives
## to zero. This may violate the Geneva Convention.
@export_range(10, 500, 10) var time := 430:
	set(value):
		time = clamp(value, 10, 500)
## The clear condition for this level.
@export var clear_condition := ClearCondition.NONE
## A reference to the current [Player]. If this is not filled in with the
## inspector, a player will be automatically spawned in the
## [member current_sub_area].
@export var player: Player
## The current [SubArea], that is, the [SubArea] in which entities are active
## and the player is in.
@export var current_sub_area: SubArea
## Whether the level is currently playing.

## The level's automatically assigned sub-areas.
var sub_areas: Array[SubArea] = []

var _timer: Timer


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
	if current_sub_area == null:
		current_sub_area = sub_areas[0]

	_timer = Timer.new()
	add_child(_timer)
	_timer.wait_time = time + 1
	_timer.one_shot = true
	_timer.timeout.connect(_timeout)
	if editor == null:
		if player == null:
			player = load("uid://b2cwk2viytb57").instantiate()
			current_sub_area.spawn(player, Vector2(64, -32))
		var hud: HUD = load(GameConstants.HUDS[game_style]).instantiate()
		hud.level = self
		add_child(hud)
		_timer.start()


## Starts the level.
func play() -> void:
	editor.spawn_tiles()


func edit() -> void:
	pass


func get_current_time() -> int:
	if _timer == null:
		return time
	else:
		return int(_timer.time_left)


func reload() -> void:
	SceneManager.fade_to_scene(load(scene_file_path))


func to_grid(pos: Vector2) -> Vector2i:
	return Vector2i((pos / GRID_SIZE).floor())


func from_grid(pos: Vector2i) -> Vector2:
	return Vector2(pos) * GRID_SIZE


func snap(pos: Vector2) -> Vector2:
	return (pos / GRID_SIZE).floor() * GRID_SIZE


func _timeout() -> void:
	times_up.emit()
	player.kill()
