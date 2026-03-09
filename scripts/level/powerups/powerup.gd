class_name Powerup
extends Resource
## Represents a powerup.

var player: Player


static func default_animate(
		tree: SceneTree,
		old_graphics: Node2D,
		new_graphics: Node2D
) -> void:
	tree.paused = true
	var tween = tree.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(old_graphics, "visible", false, 0.1)
	new_graphics.visible = false
	tween.parallel().tween_property(new_graphics, "visible", true, 0.1)
	tween.tween_property(old_graphics, "visible", true, 0.1)
	tween.parallel().tween_property(new_graphics, "visible", false, 0.1)
	tween.tween_property(old_graphics, "visible", false, 0.1)
	tween.parallel().tween_property(new_graphics, "visible", true, 0.1)
	tween.tween_property(old_graphics, "visible", true, 0.1)
	tween.parallel().tween_property(new_graphics, "visible", false, 0.1)
	tween.tween_property(old_graphics, "visible", false, 0.1)
	tween.parallel().tween_property(new_graphics, "visible", true, 0.1)
	tween.finished.connect(func(): tree.paused = false; old_graphics.queue_free())


## Runs once the state has just been enabled.
@warning_ignore("unused_parameter", "shadowed_variable")
func start(animate := false) -> void:
	pass


## Runs once the state is just about to stop in favor of a new powerup.
func end() -> void:
	pass


## Runs every frame. Clone of [method Node._process].
@warning_ignore("unused_parameter")
func process(delta: float) -> void:
	pass

## Runs every physics tick. Clone of [method Node._physics_process].
@warning_ignore("unused_parameter")
func physics_process(delta: float) -> void:
	pass
