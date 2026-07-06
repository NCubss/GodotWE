class_name LevelCard
extends TextureButton

var hover := ButtonHoverEffect.new(self)
@export var level: Level
@export var path: String:
	set = _set_path
@export var coursebot: Coursebot


static func create(_path: String, _coursebot: Coursebot) -> LevelCard:
	var card = preload("uid://to3p8asx0wuv").instantiate()
	card.path = _path
	card.coursebot = _coursebot
	return card


func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func _process(_delta: float) -> void:
	hover.check_redraw()


func _draw() -> void:
	hover.draw()


func _pressed() -> void:
	%Sounds.stream = preload("uid://xgqdhf77bhmt")
	%Sounds.play()
	if level == null:
		level = await LevelProcessor.from_swe(path, true)
	coursebot.transition(await LevelView.create(coursebot, path, level), false)


func _mouse_entered() -> void:
	hover.start()
	UISoundPlayer.stream = preload("uid://bbc6fa1b5njqq")
	UISoundPlayer.play()


func _mouse_exited() -> void:
	hover.stop()


func _set_path(v: String) -> void:
	path = v
	%Label.text = v.get_basename().get_file()
