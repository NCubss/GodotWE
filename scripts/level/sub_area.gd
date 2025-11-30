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
