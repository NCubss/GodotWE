class_name PlayerDeathState
extends State


func _init() -> void:
	intended_class = Player


func start(entity: Node2D) -> Variant:
	var player: Player = entity
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.level.process_mode = Node.PROCESS_MODE_DISABLED
	if player.global_position.y > player.VOID_LEVEL:
		player.sprite.hide()
	else:
		player.sprite.play("dead", 0)
	MusicPlayer.stop()
	UISoundPlayer.stream = load("uid://cpvqy2k0d2cju")
	UISoundPlayer.play()
	var grav_comp: GravityComponent = Utility.find_child_by_class(player,
			GravityComponent)
	grav_comp.gravity = Vector2.ZERO
	player.collision_mask = 0
	player.collision_layer = 0
	player.velocity = Vector2.ZERO
	
	get_tree().create_timer(0.5).timeout.connect(_fall.bind(player, grav_comp))
	
	return


func _fall(player: Player, grav_comp: GravityComponent) -> void:
	player.sprite.play("dead")
	grav_comp.gravity = Vector2(0, 12)
	grav_comp.max_fall_speed = 240
	player.velocity = Vector2(0, -210)
	get_tree().create_timer(2).timeout.connect(player.level.reload)
