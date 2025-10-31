class_name GrabComponent
extends Node

@export var area_path: NodePath
@export var follow_speed: float = 100.0  # velocidad al seguir

var _area: Area2D
var _target: Node = null
var _owner: Node = null


func _ready() -> void:
	_owner = owner
	_area = get_node(area_path)
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	# Cuando algo entra al área, lo guardamos como posible objetivo
	_target = body


func _on_body_exited(body: Node) -> void:
	# Si sale el mismo objeto, dejamos de seguirlo
	if _target == body:
		_target = null


func _physics_process(delta: float) -> void:
	if _target and Input.is_action_pressed("player_run"):
		var dir = (_target.global_position - _owner.global_position).normalized()
		_owner.global_position += dir * follow_speed * delta
