class_name SubArea
extends Node2D
## Represents a separated world in a level.

@export var game_theme := Level.GameTheme.OVERWORLD
@export var night_mode := false
@export var water_speed := Level.WaterSpeed.SLOW
@export var min_water_height := 1
@export var max_water_height := 1
@export var meteorites := false
@export var autoscroll := Level.Autoscroll.NONE
