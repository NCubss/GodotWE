class_name PickupComponent
extends Component
## A component that provides pick-up functionality for gameplay items.
##
## The [PickupComponent] provides basic pick-up detection and handling via
## signals.
## [br][br]
## Some examples include springs, shells, POW blocks. Once the player runs into
## them (while running), the player picks up the item. Once the player lets go
## of the run button, the item will be kicked by the player in the direction the
## player is facing. If the player ducks while letting go of the run button,
## the item will be placed down with no additional movement. If the player looks
## up while letting go of the run button, the item will be kicked up.
## [br][br]
## Note that picking up items is [b]not possible in the SMB game style.[/b]
## Custom game style support is coming in the future, where functionality like
## this will be toggleable.
## [br][br]
## Once an item is picked up, the entity node is put inside of the player node,
## and the player node [b]takes control of the entity node's position[/b]. The
## entity's body collisions will also be disabled.

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

## Emitted when the player picks up the item. The player emits this signal when
## [member Player.held_item] is set to a new item.
signal picked_up(player: Player)
## Emitted when the player lets go of the item. The player emits this signal
## when 
signal dropped(release_type: ReleaseType)

## The area used to detect the player for pick-ups. Must have the player
## collision mask selected.
@export var check_area: Area2D
## Whether the player can hold this item. If this is set to [code]false[/code],
## the player will not pick up the item even in the right conditions.
var can_be_held := true

## Whether this item is currently held by the player. If the item is held,
## the player takes control of the item's position and shouldn't be changed by
## anything except the player.
var held := false


func _ready() -> void:
	check_area.body_entered.connect(_body_entered)
	picked_up.connect(func(_player): held = true)
	dropped.connect(func(_player): held = false)
	

func _body_entered(body: Node2D) -> void:
	var player = body as Player
	if player == null or not can_be_held or not get_parent().is_on_floor():
		return
	player.give_item(get_parent())
