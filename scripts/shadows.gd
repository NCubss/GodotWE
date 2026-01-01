extends SubViewportContainer

@onready var shadow_vp: SubViewport = %ShadowViewport
@onready var level_vp: SubViewport = %LevelViewport


func _ready() -> void:
	shadow_vp.world_2d = level_vp.world_2d
	shadow_vp.global_canvas_transform.origin = Vector2(9, 9)
