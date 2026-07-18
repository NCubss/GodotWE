class_name PickupComponent
extends Component
## Makes an [Entity] holdable by the [Player].
##
## The [PickupComponent] is required for the [Player] to be able to hold an
## entity. The component also provides default behavior for items.

## Represents the way an item was released by the player.
enum ReleaseType {
	## The item was kicked in the player's direction. This release type happens
	## when the player lets go of the item with no additional actions.
	KICKED,
	## The item was thrown up above the player. This release type happens when
	## the player lets go and is looking up simultaneously.
	THROWN_UP,
	## The item was dropped next to the player. This release type happens when
	## the player lets go and is ducking simultaneously.
	DROPPED,
}

## Emitted when the player picks up the item. Note that the item won't be in its
## held position yet when the signal is emitted. There isn't a convenient way to
## get this position, as you would have to wait until the next frame ends.
signal picked_up(player: Player)
## Emitted when the player lets go of the item along with the way it was
## released by the player.
signal dropped(player: Player, release_type: ReleaseType)

## The area used to detect the player for pick-ups. Must have the player
## collision mask selected.
@export var check_area: Area2D:
	set = _set_check_area
## Whether the player can hold this item. If this is set to [code]false[/code],
## the player will not pick up the item even in the right conditions.
var can_be_held := true
## Whether the item uses the default dropping behavior. This should be kept on
## for consistency across items, however you are free to create your own unique
## behavior if the default does not fit your needs.
var use_default_behavior := true

var _player: Player


func _ready() -> void:
	# trigger setter
	#check_area = check_area
	picked_up.connect(_picked_up)
	dropped.connect(_dropped)


## Returns the [Player] currently holding this item or [code]null[/code] if no
## one is holding it. Can be used to check whether this item is being held.
func get_holder() -> Player:
	return _player


func _body_entered(body: Node2D) -> void:
	var player = body as Player
	if player == null or not can_be_held:
		return
	if not Input.is_action_pressed("player_run"):
		return
	player.give_item(get_parent())


func _picked_up(player: Player) -> void:
	_player = player


func _dropped(player: Player, release_type: ReleaseType) -> void:
	_player = null
	match release_type:
		ReleaseType.KICKED:
			# i am currently just guessing values cause the code is lying to me
			get_parent().velocity = Vector2(
				(120 + absf(player.velocity.x)) * player.direction,
				-90
			)
		ReleaseType.THROWN_UP:
			get_parent().velocity = Vector2(
				30 * player.direction,
				-367.5
			)
			if player.velocity.x == 0:
				get_parent().velocity.x = 0


func _set_check_area(v: Area2D) -> void:
	if check_area != null:
		check_area.body_entered.disconnect(_body_entered)
	if v != null and not v.body_entered.is_connected(_body_entered):
		v.body_entered.connect(_body_entered)
	check_area = v
