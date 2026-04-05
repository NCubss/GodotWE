class_name TurnBlockTile
extends StaticBodyExt

const TURNS = 8

var turning := false:
	set(value):
		if value:
			turns_done = 0
			$Sprite.play("turning")
			$CollShape.disabled = true
		else:
			$Sprite.play("idle")
			$CollShape.disabled = false
var turns_done := 0

func _sprout_end(_eject_direction: Vector2, _activator: PhysicsBody2D) -> void:
	turning = true

func _sprite_animation_looped() -> void:
	turns_done += 1
	if turns_done >= TURNS and not $PlayerCheckArea.overlaps_body(
			Utility.id("player")):
		turning = false
