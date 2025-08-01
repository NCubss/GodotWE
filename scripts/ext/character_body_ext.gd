class_name CharacterBodyExt
extends CharacterBody2D
## A modified version of [CharacterBody2D] that adds useful collision signals.

## Fired when a collision occurs. Can be fired back-to-back for equal
## collisions.
signal collided(collision: KinematicCollision2D)

## Fired when a collision occurs. Does not fire on back-to-back equal
## collisions.
signal just_collided(collision: KinematicCollision2D)

## Array of all bodies this body has collided with last frame.
var last_collided: Array[Node2D] = []

func _physics_process(_delta: float) -> void:
	var data = {}
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		data[collision.get_collider()] = collision
	for i in Utility.array_merge(last_collided, data.keys()):
		if i in last_collided and not data.has(i):
			last_collided.erase(i)
		elif i in last_collided and data.has(i):
			collided.emit(data[i])
			if i is CharacterBodyExt or i is StaticBodyExt:
				i.collided.emit(data[i])
		elif i not in last_collided and data.has(i):
			last_collided.append(i)
			just_collided.emit(data[i])
			collided.emit(data[i])
			if i is CharacterBodyExt or i is StaticBodyExt:
				i.just_collided.emit(data[i])
				i.collided.emit(data[i])
