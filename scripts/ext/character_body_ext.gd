class_name CharacterBodyExt
extends CharacterBody2D
## A modified version of [CharacterBody2D] that adds useful collision signals.

## Fired when a collision occurs. Can be fired back-to-back for equal
## collisions.
signal collided(collision: KinematicCollisionExt)

## Fired when a collision occurs. Does not fire on back-to-back equal
## collisions.
signal just_collided(collision: KinematicCollisionExt)

## Array of all bodies this body has collided within the last [method
## move_and_slide] call.
var last_collided: Array[Node2D] = []


func _enter_tree() -> void:
	# don't interpolate on first frame to prevent visible jumps from (0, 0)
	reset_physics_interpolation.call_deferred()


func _physics_process(_delta: float) -> void:
	var collisions = {}

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		collisions[collision.get_collider()] = collision

	for collider in Utility.array_merge(
				last_collided.duplicate(), collisions.keys()):
		# already collided
		if collider in last_collided:
			if collider in collisions:
				collisions[collider].set_script(KinematicCollisionExt)
				collisions[collider].local = self
				collided.emit(collisions[collider])
				if collider is StaticBodyExt:
					collider.collided.emit(collisions[collider])
			else:
				last_collided.erase(collider)
		# just collided
		elif collider in collisions:
			collisions[collider].set_script(KinematicCollisionExt)
			collisions[collider].local = self
			last_collided.append(collider)
			just_collided.emit(collisions[collider])
			collided.emit(collisions[collider])
			if collider is StaticBodyExt:
				collider.just_collided.emit(collisions[collider])
				collider.collided.emit(collisions[collider])
