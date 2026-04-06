class_name CoinSprout
extends Sprout


func start_sprout(position: Vector2, direction: Vector2) -> void:
	var coin = Sprouter.new()
	coin.global_position = position + Vector2(0, 8)
	coin.body = body
	coin.downwards = direction.y > 0
	body.add_sibling(coin)
	empty = true


class Sprouter extends AnimatedSprite2D:
	const GRAVITY = 12.0
	
	var body: PhysicsBody2D
	var y_speed: float
	var downwards: bool
	var start_y: float
	
	
	func _ready() -> void:
		start_y = global_position.y
		sprite_frames = preload("uid://bbjiq1okyrimt")
		play()
		if downwards:
			y_speed = 180
		else:
			y_speed = -240
		var player: Player = Utility.id(&"player")
		player.get_node(^"%Coin").play()
		player.coins += 1
	
	
	func _process(delta: float) -> void:
		if (global_position.y > start_y - 20 and y_speed > 0 and not downwards)\
				or (global_position.y < start_y + 20 and y_speed < 0 and downwards):
			var sparkle = preload("uid://b4pkpe44vveuw").instantiate()
			sparkle.global_position = global_position - Vector2(8, 8)
			add_sibling(sparkle)
			queue_free()
		global_position.y += y_speed * delta
		y_speed += GRAVITY
