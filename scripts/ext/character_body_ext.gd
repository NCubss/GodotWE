class_name CharacterBodyExt
extends CharacterBody2D
## A modified version of [CharacterBody2D] that adds useful collision signals.

## Fired when a collision occurs. Can be fired back-to-back for equal
## collisions.
signal collided(collision: KinematicCollision2D)

## Fired when a collision occurs. Does not fire on back-to-back equal
## collisions.
signal just_collided(collision: KinematicCollision2D)

## Array of all bodies this body has collided within the last [method
## move_and_slide] call.
var last_collided: Array[Node2D] = []


func _physics_process(_delta: float) -> void:
	var collisions = {}

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		collisions[collision.get_collider()] = collision

	for collider in Utility.array_merge(
				last_collided, collisions.keys()):
		# already collided
		if collider in last_collided:
			if collider in collisions:
				collided.emit(collisions[collider])
				if collider is StaticBodyExt:
					collider.collided.emit(collisions[collider])
			else:
				last_collided.erase(collider)
		# just collided
		elif collider in collisions:
			last_collided.append(collider)
			just_collided.emit(collisions[collider])
			collided.emit(collisions[collider])
			if collider is StaticBodyExt:
				collider.just_collided.emit(collisions[collider])
				collider.collided.emit(collisions[collider])
