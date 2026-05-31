class_name HUD
extends CanvasLayer

@export var time_label: Label
@export var score_label: Label
@export var lives_label: Label
@export var coins_label: Label

# 当前显示的金币
var cur_coin: int = 0
# 还要加的金币
var need_add_coin:int = 0


## The level associated with this HUD.
var level: Level
## The player currently being kept track of.
var player: Player:
	set(val):
		player = val
		cur_coin = val.coins
		need_add_coin = 0
		update_coins_label()


func _enter_tree() -> void:
	# 我不确定这样做对不对
	assert(
		_on_player_add_coin.callv
		 == _on_player_add_coin.callv
	)
	EventBus.subscribe(
		EventBusConstants.N_PLAYER_ADDED_COIN,
		_on_player_add_coin.callv
	)

func _exit_tree() -> void:
	
	EventBus.unsubscribe(
		EventBusConstants.N_PLAYER_ADDED_COIN,
		_on_player_add_coin.callv
	)


func _on_player_add_coin(tar: Player, coin:int):
	if tar != player:
		return
	need_add_coin += coin

func _physics_process(_delta: float) -> void:
	time_label.text = "%03d" % level.get_current_time()
	if player != null:
		if need_add_coin > 0:
			update_coins_label()


func update_coins_label():
	if need_add_coin > 0:
		cur_coin += 1
		need_add_coin -= 1
	
	coins_label.text = "%02d" % cur_coin
