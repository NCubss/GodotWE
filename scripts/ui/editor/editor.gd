class_name Editor
extends Control
## The game's editor.
##
## The [Editor] manages the level view while editing the level. [Part]s are
## tightly integrated with the editor as it handles keeping track of held parts,
## whether they can be interacted with and how they are interacted with. It also
## shares a reference to the level itself for the rest of the editor UI.

## Emitted when the editor is ready (i.e. [member level] has been set).
signal loaded
signal erase_started
signal erase_stopped

enum EraseMode {
	NONE,
	TOGGLE_ERASE,
	QUICK_ERASE,
}

## The level this [Editor] is associated with.
var level: Level
## The currently held part.
var held_part: Part
## The part that the mouse is currently on.
var hovered_part: Part
## Whether the editor is in erase mode and how it has been activated.
var erasing := EraseMode.NONE:
	set = _set_erasing
## The currently displayed touch effect. Used to limit one at a time.
var touch_effect: AnimatedSprite2D
## The editor [Grid].
var grid := Grid.new()
## Whether parts can currently be placed and interacted with.
var part_interact := true

# The last calculated grid spot the mouse is on.
var _last_mouse_pos: Vector2i


func _ready():
	grid.z_index = -1
	grid.minor_color = Color("00000099")
	grid.major_color = Color("000000ff")
	grid.modulate = Color("ffffff40")
	
	theme = ThemeDB.get_project_theme()
	
	%LeftPanel.status = EditorPanel.Status.OPEN
	%TopPanel.status = EditorPanel.Status.OPEN
	%RightPanel.status = EditorPanel.Status.OPEN
	%Clapperboard.off_screen = false


func _process(_delta: float) -> void:
	_process_placing(true)
	
	if Input.is_action_pressed(&"quick_erase") and held_part == null \
			and part_interact:
		erasing = EraseMode.QUICK_ERASE
	elif erasing == EraseMode.QUICK_ERASE:
		erasing = EraseMode.NONE
	
	if erasing != EraseMode.NONE:
		var erase_button
		if erasing == EraseMode.TOGGLE_ERASE:
			erase_button = &"erase"
		elif erasing == EraseMode.QUICK_ERASE:
			erase_button = &"quick_erase"
		
		if Input.is_action_pressed(erase_button):
			Cursor.down = true
			if hovered_part != null:
				hovered_part.erase()
		else:
			Cursor.down = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place"):
		_process_placing(false)


## Returns the currently selected [Part] script from the card bar on the top
## panel. If no [Part] is selected, [code]null[/code] is returned.
func get_selected_part() -> Script:
	var card: EditorCard = preload("uid://dhdt3ovnv8ci2").get_pressed_button()
	if card == null:
		return null
	else:
		return card.part


## Places a tile at [param pos] and returns the placed [Part].
func place(pos: Vector2i) -> Part:
	UISoundPlayer.stream = preload("uid://2x6kk0s4njjp")
	UISoundPlayer.play()
	
	var part: Part = get_selected_part().create()
	part.global_position = Level.from_grid(pos)
	level.current_sub_area.add_part(part)
	part.load(true)
	
	return part


## Called by the [Level] when it has given the editor a reference to itself and
## the editor needs to do initialization with it.
func load() -> void:
	MusicPlayer.stream = preload("uid://dq3thvj6cinc0")
	MusicPlayer.play.call_deferred()
	
	level.add_child(grid)
	level.playing.connect(_play)
	level.editing.connect(_edit)
	
	loaded.emit()


func _process_placing(process_multiplaceables: bool) -> void:
	_last_mouse_pos = level.get_global_mouse_position()
	
	var selected = get_selected_part()
	if selected == null or not Input.is_action_pressed("place"):
		return
	if not part_interact or erasing != EraseMode.NONE or not has_focus():
		return
	# makes sure whether this method should place multiplaceable parts,
	# as multiplaceable and non-multiplaceable are handled in different places
	if selected.is_multiplaceable() != process_multiplaceables:
		return
	if held_part != null:
		return
	
	if selected.is_placeable(Level.to_grid(_last_mouse_pos), get_world_2d()):
		place(Level.to_grid(_last_mouse_pos))


func _play() -> void:
	part_interact = false
	%TopPanel.status = EditorPanel.Status.HIDDEN
	%LeftPanel.status = EditorPanel.Status.HIDDEN
	%RightPanel.status = EditorPanel.Status.HIDDEN
	grid.hide()


func _edit() -> void:
	MusicPlayer.stream = preload("uid://dq3thvj6cinc0")
	MusicPlayer.play()
	
	part_interact = true
	%TopPanel.status = EditorPanel.Status.OPEN
	%LeftPanel.status = EditorPanel.Status.OPEN
	%RightPanel.status = EditorPanel.Status.OPEN
	grid.show()


func _set_erasing(v: EraseMode) -> void:
	if v == erasing:
		return
	erasing = v
	if v == EraseMode.NONE:
		%EraseBG.hide()
		Cursor.set_to_player()
		Cursor.down = false
		erase_stopped.emit()
	else:
		%EraseBG.show()
		Cursor.type = Cursor.Type.ERASER
		Cursor.down = true
		erase_started.emit()
