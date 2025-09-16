class_name SuperPowerup
extends Powerup


func start(animate := true) -> void:
	var coll_shape = player.get_node("CollShape") as CollisionShape2D
	coll_shape.position = player.BIG_HITBOX_SIZE.position
	coll_shape.shape.size = player.BIG_HITBOX_SIZE.size
	if animate:
		player.sounds.stream = preload("res://audio/player/powerup.wav")
		player.sounds.play()
		var new_graphics = Node2D.new()
		var new_sprite = AnimatedSpriteExt.new()
		new_sprite.sprite_frames = preload("res://sprites/player/mario/super.tres")
		new_sprite.animation = player.sprite.animation
		new_sprite.frame = player.sprite.frame
		new_sprite.speed_scale = player.sprite.speed_scale
		new_sprite.flip_h = player.sprite.flip_h
		new_sprite.position = Vector2(0, -15)
		new_graphics.add_child(new_sprite)
		player.add_child(new_graphics)
		player.sprite = new_sprite
		default_animate(player.get_tree(), player.graphics, new_graphics)
		player.graphics = new_graphics
		
