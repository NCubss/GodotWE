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

## Emitted when the player picks up the item.
signal picked_up(player: Player)

## The area used to detect the player for pick-ups. Must have the player
## collision mask selected.
@export var check_area: Area2D

## Whether this item is currently held by the player. If the item is held,
## the player takes control of the item's position and shouldn't be changed by
## anything except the player.
var held := false


func _ready() -> void:
	check_area.body_entered.connect(_body_entered)
	randf()


func _body_entered(body: Node2D) -> void:
	body = body as Player
	if body == null:
		return
	var area_coll_shape = Utility.find_child_by_class(
			check_area, CollisionShape2D) as CollisionShape2D
	if area_coll_shape == null:
		return
	var area_rect = area_coll_shape.shape.get_rect()
	area_rect.position += area_coll_shape.global_position
	var player_coll_shape = Utility.find_child_by_class(
			body, CollisionShape2D) as CollisionShape2D
	if player_coll_shape == null:
		return
	var player_rect = player_coll_shape.shape.get_rect()
	player_rect.position += player_coll_shape.global_position
	var midpoint = area_rect.get_center().lerp(player_rect.get_center(), 0.5)
	var spin_thump = preload("res://scenes/particles/spin_thump.tscn") \
			.instantiate()
	get_parent().add_sibling(spin_thump)
	spin_thump.global_position = midpoint
