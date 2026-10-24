@tool
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

const JUST_THROWN_TIME = 0.25

## The shape for this item. Pickup hitboxes are derived from this rectangle.
@export var check_rect: Rect2:
	set = _set_check_rect
## Whether the player can hold this item. If this is set to [code]false[/code],
## the player will not pick up the item even in the right conditions.
var can_be_held := true
## Whether the item uses the default dropping behavior. This should be kept on
## for consistency across items, however you are free to create your own unique
## behavior if the default does not fit your needs.
var use_default_behavior := true
## The physics tick in which this component was ready. Used to prevent immediate
## pickups when the entity enters the tree.
var start_tick: int
## Whether this item was thrown within the last [constant JUST_THROWN_TIME]
## seconds. Used for not allowing the player to grab the item when it has just
## been thrown. In the SMM:WE codebase, this is equivalent to
## [code]inmune[/code], which prevents pickups and kicks to prevent unwanted
## behavior. This is why you may find this variable referenced in seemingly
## unrelated places.
var just_thrown := false
## The timer that updates [member just_thrown].
var just_thrown_timer := Timer.new()
## The [PickupComponent.Preview], only available under [method
## Engine.is_editor_hint].
var tool_preview: PickupComponent.Preview

var _player: Player


func _ready() -> void:
	if Engine.is_editor_hint():
		tool_preview = PickupComponent.Preview.new()
		tool_preview.comp = self
		add_child(tool_preview, false, Node.INTERNAL_MODE_FRONT)
		return
	
	picked_up.connect(_picked_up)
	dropped.connect(_dropped)
	start_tick = Engine.get_physics_frames()
	
	add_child(just_thrown_timer)
	just_thrown_timer.one_shot = true
	just_thrown_timer.wait_time = JUST_THROWN_TIME
	just_thrown_timer.timeout.connect(func(): just_thrown = false)


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	# make sure the player won't hold a destroyed object
	if _player != null and _player.held_item == self:
		_player.drop_item()


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if just_thrown:
		return
	if not Input.is_action_pressed(&"player_run"):
		return
	# TODO: consider making a player reference like Level.player
	var player: Player = get_parent().level.player
	var rect = get_check_rect(player.direction)
	rect.position = get_parent().to_global(rect.position)
	var query = PhysicsShapeQueryParameters2D.new()
	query.collision_mask = 1 << 2
	query.shape = RectangleShape2D.new()
	query.shape.size = rect.size
	query.transform.origin = rect.get_center()
	var result = get_viewport().world_2d.direct_space_state.intersect_shape(
			query, 1)
	if result.size() == 0:
		return
	player.give_item(get_parent())


## Returns the [Player] currently holding this item or [code]null[/code] if no
## one is holding it. Can be used to check whether this item is being held.
func get_holder() -> Player:
	return _player


func get_check_rect(direction: int) -> Rect2:
	var size = Vector2(6, check_rect.size.y - 12)
	if direction == 1:
		return Rect2(check_rect.position + Vector2(-6, 8), size).abs()
	elif direction == -1:
		return Rect2(check_rect.position + Vector2(check_rect.size.x, 8),
				size).abs()
	return Rect2(NAN, NAN, NAN, NAN)


func _body_entered(body: Node2D) -> void:
	var player = body as Player
	if Engine.get_physics_frames() <= start_tick + 1:
		return
	if player == null or not can_be_held:
		return
	if not Input.is_action_pressed("player_run"):
		return
	player.give_item(get_parent())


func _picked_up(player: Player) -> void:
	_player = player
	get_parent().reset_physics_interpolation.call_deferred()


func _dropped(player: Player, release_type: ReleaseType) -> void:
	_player = null
	
	just_thrown = true
	just_thrown_timer.start()
	
	match release_type:
		ReleaseType.KICKED:
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
		ReleaseType.DROPPED:
			get_parent().velocity = Vector2(
				get_parent().velocity.x / 2,
				0
			)
			if player.velocity.x == 0:
				get_parent().velocity.x = 0.7 * player.direction


func _set_check_rect(v: Rect2) -> void:
	check_rect = v
	if Engine.is_editor_hint():
		tool_preview.queue_redraw()


## Internal node that draws a preview of this [PickupComponent], only under
## [method Engine.is_editor_hint].
class Preview extends Node2D:
	var comp: PickupComponent
	
	
	func _draw() -> void:
		draw_rect(comp.check_rect, Color(Color.WHITE, 0.5))
		draw_rect(comp.check_rect, Color.WHITE, false)
		text(comp.check_rect, "BODY")
		
		var left_rect = comp.get_check_rect(1)
		draw_rect(left_rect, Color(Color.GREEN, 0.5))
		draw_rect(left_rect, Color.GREEN, false)
		text(left_rect, "LEFT")
		
		var right_rect = comp.get_check_rect(-1)
		draw_rect(right_rect, Color(Color.RED, 0.5))
		draw_rect(right_rect, Color.RED, false)
		text(right_rect, "RIGHT")
	
	
	func text(r: Rect2, t: String) -> void:
		draw_string(ThemeDB.fallback_font, r.position + Vector2(0, 1), t,
				HORIZONTAL_ALIGNMENT_LEFT, r.size.x, 1)
