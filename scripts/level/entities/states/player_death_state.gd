class_name PlayerDeathState
extends State

var _death_timer: Timer


func _init() -> void:
	intended_class = Player
	_death_timer = Timer.new()
	add_child(_death_timer)


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
	
	_death_timer.start(0.5)
	_death_timer.timeout.connect(_fall.bind(player, grav_comp),
			ConnectFlags.CONNECT_ONE_SHOT)
	
	return


func _fall(player: Player, grav_comp: GravityComponent) -> void:
	player.sprite.play("dead")
	grav_comp.gravity = Vector2(0, 12)
	grav_comp.max_fall_speed = 240
	player.velocity = Vector2(0, -210)
	_death_timer.start(2)
	_death_timer.timeout.connect(func():
		if player.level.editor == null:
			player.level.reload()
		else:
			player.level.edit()
	)
