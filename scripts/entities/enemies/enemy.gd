class_name Enemy
extends Entity
## Represents an enemy with configurable settings on how it interacts with the
## player.

## Fired when the enemy is stomped on by the player.
signal stomped(player: Player)

## The hitbox [Area2D] this enemy will use to damage the player.
@export var hitbox: Area2D


func kill() -> void:
	var grav: GravityComponent
	for i in get_children():
		if i is GravityComponent:
			grav = i
		else:
			i.process_mode = Node.PROCESS_MODE_DISABLED
	var tween = create_tween()
	# shadows
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property($Graphics, "rotation", 0, 0)
	tween.tween_property($Graphics, "rotation", 2 * PI, 0.5)
	tween.set_loops()
	grav.gravity = Vector2(0, 10)


func _ready() -> void:
	if hitbox == null:
		push_warning("Enemy does not have a damage hitbox! ",
				"Please add one via the \"hitbox\" variable.")
		return
	hitbox.body_entered.connect(_body_entered)
	stomped.connect(_stomped)
	$SlideComponent.turned.connect(_turned)


func _stomped(player: Player) -> void:
	player.velocity.y = -200
	var dead_graphics: Node2D = $Graphics.duplicate()
	dead_graphics.set_script(DeadEntity)
	add_sibling(dead_graphics)
	queue_free()


func _turned(direction: Vector2) -> void:
	if direction == Vector2.LEFT:
		$Graphics/Sprite.flip_h = true
	elif direction == Vector2.RIGHT:
		$Graphics/Sprite.flip_h = false
	

func _physics_process(_delta: float) -> void:
	move_and_slide()


func _body_entered(body: Node2D) -> void:
	var player = body as Player
	if player == null:
		return
	if player.velocity.normalized().y > 0.75:
		stomped.emit(player)
	else:
		player.damage()
