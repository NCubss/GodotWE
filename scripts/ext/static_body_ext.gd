class_name StaticBodyExt
extends StaticBody2D
## A modified version of [StaticBody2D] that adds useful collision signals.
## 
## Unlike [CharacterBodyExt], this does not check for collision and relies on
## [CharacterBodyExt] to report collisions.

## Fired when a collision occurs. Can be fired back-to-back for equal
## collisions.
signal collided(collision: KinematicCollision2D)

## Fired when a collision occurs. Does not fire on back-to-back equal
## collisions.
signal just_collided(collision: KinematicCollision2D)
