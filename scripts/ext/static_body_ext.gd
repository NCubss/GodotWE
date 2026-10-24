class_name StaticBodyExt
extends StaticBody2D
## A modified version of [StaticBody2D] that adds useful collision signals.
##
## Unlike [CharacterBodyExt], this does not check for collision and relies on
## [CharacterBodyExt] to report collisions.

## Fired when a collision occurs. Can be fired back-to-back for equal
## collisions.
@warning_ignore("unused_signal")
signal collided(collision: KinematicCollisionExt)

## Fired when a collision occurs. Does not fire on back-to-back equal
## collisions.
@warning_ignore("unused_signal")
signal just_collided(collision: KinematicCollisionExt)


func _enter_tree() -> void:
	# don't interpolate on first frame to prevent visible jumps from (0, 0)
	reset_physics_interpolation.call_deferred()
