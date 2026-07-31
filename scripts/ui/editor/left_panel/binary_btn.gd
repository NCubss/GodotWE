class_name BinaryBtn
extends TextureButton

enum Type {
	MUSIC,
	TRAIL,
	METEORITES,
}

@export var type: Type

var sounds := AudioStreamPlayer.new()

@onready var effect := ButtonHoverEffect.new(self)

func _ready() -> void:
	sounds.name = "Sounds"
	add_child(sounds)
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func _process(_delta: float) -> void:
	effect.check_redraw()


func _draw() -> void:
	effect.draw()


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		sounds.stream = preload("uid://5pu1mo481hb4")
	else:
		sounds.stream = preload("uid://r55em6pfkmqk")
	sounds.play()
	# TODO
	match type:
		Type.MUSIC:
			pass
		Type.TRAIL:
			pass
		Type.METEORITES:
			pass


func _mouse_entered() -> void:
	if not disabled:
		UISoundPlayer.stream = preload("uid://d3lha2xpakko2")
		UISoundPlayer.play()
		effect.start()


func _mouse_exited() -> void:
	effect.stop()
