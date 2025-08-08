class_name BlockComponent
extends Component
## Provides generic block functionality, such as being activated or containing
## an item.[br]
## 
## Not to be confused with the [TileComponent], the [BlockComponent] provides
## the ability for the parent to be activated, whether the activator hits it
## from below, ground-pounds, or another type of activation method.
## [br][br]
## The component also provides container functionality, specifically storing a
## type of [Sprout] and releasing it once the block has been activated.
## [br][br]
## The component [b]will not function[/b] if the owner is not a [StaticBodyExt]
## or [CharacterBodyExt].

## Fired when the block has just been activated and is starting to scale the
## sprite up.
signal sprout_start(eject_direction: Vector2, activator: PhysicsBody2D)
## Fired when the block sprite is starting to scale down. This would be when a
## question block becomes an empty block, for example.
signal sprout_end(eject_direction: Vector2, activator: PhysicsBody2D)

## If [code]true[/code], the contained sprout class in
## [member BlockComponent.sprout] will be released upon activation. Otherwise,
## nothing will happen by default.
@export var release_sprout := false
## The sprout to spawn. Is not used if
## [member BlockComponent.release_sprout] is set to [code]false[/code].
@export var sprout: PackedScene
## The sprite the component will animate. Will not animate if it is
## [code]null[/code]. If you want to animate multiple sprites at once, group
## them together in a [Node2D].
@export var sprite: Node2D

var _sprout: Sprout = null

## Animates the given [param spr] with the starting sprout animation.
static func animate_sprout_start(spr: Node2D) -> Tween:
	# shadow sprites are updated in process event, so tweens should update
	# before that
	var tween = spr.create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(spr, "position", Vector2(8, -2), 4/60.0) 
	tween.parallel().tween_property(spr, "scale", Vector2(1.1875, 1.1875), 4/60.0) 
	tween.tween_property(spr, "position", Vector2(8, 5), 4/60.0) 
	tween.parallel().tween_property(spr, "scale", Vector2(1.375, 1.375), 4/60.0)
	return tween


## Animates the given [param spr] with the ending sprout animation.
static func animate_sprout_end(spr: Node2D) -> Tween:
	spr.position = Vector2(8, 5)
	spr.scale = Vector2(1.375, 1.375)
	
	var tween = spr.create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(spr, "position", Vector2(8, 8), 4/60.0) 
	tween.parallel().tween_property(spr, "scale", Vector2(1, 1), 4/60.0)
	return tween


func _enter_tree() -> void:
	if owner is CharacterBodyExt or owner is StaticBodyExt:
		owner.just_collided.connect(_just_collided)
	else:
		printerr("Owner is not a BodyExt! ",
				"I will not be able to check for collisions!")


func _just_collided(data: KinematicCollision2D):
	var entity = data.get_local_shape().owner as PhysicsBody2D
	if entity is Player and data.get_normal().y == 1:
		if release_sprout and sprout != null:
			_sprout = sprout.instantiate()
			Utility.add_sibling_up(owner, _sprout)
			_sprout.position = owner.position + Vector2(8, 8)
			_sprout.start_sprout(Vector2(0, -1))
		sprout_start.emit(data.get_normal(), entity)
		animate_sprout_start(sprite).finished.connect(
				_finish_sprout.bind(data.get_normal(), Vector2(0, -1), entity))


func _finish_sprout(
		normal: Vector2,
		eject_direction: Vector2,
		activator: PhysicsBody2D
) -> void:
	animate_sprout_end(sprite)
	if release_sprout and sprout != null:
		#if sprout.empty_container != null:
			#var empty = sprout.empty_container.instantiate()
			#var empty_comp = Utility.find_child_by_class(empty, BlockComponent)
			#sprout.container = empty_comp
			#animate_sprout_end(empty.get_node("Sprite"))
			#var tile_comp = Utility.find_child_by_class(owner, TileComponent)
			#if tile_comp != null:
				#tile_comp.map.set_tile(tile_comp.position, empty)
		var data = _sprout.end_sprout(eject_direction)
		if data.new_tile != null:
			var new_tile = data.new_tile.instantiate()
			var tile_comp = Utility.find_child_by_class(owner, TileComponent)
			if tile_comp != null:
				tile_comp.map.set_tile(tile_comp.position, new_tile)
			else:
				owner.add_sibling(new_tile)
				owner.queue_free()
			owner.get_parent().move_child(_sprout, new_tile.get_index() - 1)
			animate_sprout_end(new_tile.get_node(^"Sprite"))
	else:
		sprout_end.emit(normal, activator)
