class_name BlockComponent
extends Component
## Provides generic block functionality, such as being activated or containing
## an item.[br]
## 
## The [BlockComponent] provides the ability for the parent to be activated,
## whether the activator hits it from below, ground-pounds, or another type of
## activation method. The component also provides container functionality using
## [Sprout]s.
## [br][br]
## [b]Note:[/b] The component will not function if the owner is not a
## [StaticBodyExt] or [CharacterBodyExt].

## Emitted when the container has just been activated. For example, coins
## typically sprout at this time. See [method Sprout.start_sprout].
signal sprout_start(eject_direction: Vector2, activator: PhysicsBody2D)
## Emitted when the container is finishing activation. For example, all items
## that rise from the container typically sprout at this time. See [method
## Sprout.end_sprout] and [member Sprout.empty].
signal sprout_end(eject_direction: Vector2, activator: PhysicsBody2D, empty: bool)

## The [Sprout] to use. Will not sprout if this is [code]null[/code].
@export var sprout: Sprout:
	set = _set_sprout
## The node the component will animate. Will not animate if it is
## [code]null[/code]. If you want to animate multiple things at once, group
## them together in a [Node2D].
@export var sprite: Node2D
## Whether this block can be activated.
@export var enabled := true

var _old_z: int


## Animates the given [param spr] with the starting sprout animation.
static func animate_sprout_start(spr: Node2D) -> Tween:
	var tween = spr.create_tween()
	tween.tween_property(spr, "position", Vector2(8, -2), 4/60.0) 
	tween.parallel() \
			.tween_property(spr, "scale", Vector2(1.1875, 1.1875), 4/60.0)
	tween.tween_property(spr, "position", Vector2(8, 5), 4/60.0) 
	tween.parallel() \
			.tween_property(spr, "scale", Vector2(1.375, 1.375), 4/60.0)
	return tween


## Animates the given [param spr] with the ending sprout animation.
static func animate_sprout_end(spr: Node2D) -> Tween:
	var tween = spr.create_tween()
	tween.tween_property(spr, "position", Vector2(8, 8), 4/60.0) \
			.from(Vector2(8, 5))
	tween.parallel().tween_property(spr, "scale", Vector2(1, 1), 4/60.0) \
			.from(Vector2(1.375, 1.375))
	return tween


func _enter_tree() -> void:
	assert(get_parent() is CharacterBodyExt or get_parent() is StaticBodyExt,
			"Node with BlockComponent must be a BodyExt")
	get_parent().just_collided.connect(_just_collided)


func _exit_tree() -> void:
	get_parent().just_collided.disconnect(_just_collided)


func _set_sprout(v: Sprout) -> void:
	sprout = v
	if not is_inside_tree():
		await tree_entered
	v.body = get_parent()


func _just_collided(data: KinematicCollision2D):
	if not enabled:
		return
	var entity = data.get_local_shape().get_parent() as PhysicsBody2D
	if entity is Player and data.get_normal().y == 1:
		if sprout != null and not sprout.empty:
			sprout.start_sprout(_get_sprout_pos(Vector2.UP), Vector2.UP)
		_old_z = get_parent().z_index
		sprite.z_index = GameConstants.Layers.Z_ANIM_BLOCKS
		sprout_start.emit(data.get_normal(), entity)
		animate_sprout_start(sprite).finished.connect(
				_finish_sprout.bind(data.get_normal(), Vector2.UP, entity))


func _finish_sprout(
		normal: Vector2,
		eject_direction: Vector2,
		activator: PhysicsBody2D
) -> void:
	animate_sprout_end(sprite) \
			.tween_property(get_parent(), "z_index", _old_z, 0)
	if sprout != null:
		sprout.end_sprout(_get_sprout_pos(eject_direction), eject_direction)
		sprout_end.emit(normal, activator, sprout.empty)


# TODO: add some sort of customizability to sprout positions
func _get_sprout_pos(dir: Vector2) -> Vector2:
	return dir * Vector2(8, 8) + get_parent().global_position + Vector2(8, 8)
