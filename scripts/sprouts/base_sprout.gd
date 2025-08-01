class_name Sprout
extends Node2D


@warning_ignore("unused_parameter")
func start_sprout(direction: Vector2) -> SproutReturnData:
	return SproutReturnData.new()


@warning_ignore("unused_parameter")
func end_sprout(direction: Vector2) -> SproutReturnData:
	return SproutReturnData.new()


class SproutReturnData:
	var new_tile: PackedScene = null
