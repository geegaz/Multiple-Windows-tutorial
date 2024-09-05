extends Window

@onready var _Camera: Camera2D = $ViewCamera

var world_offset: = Vector2i.ZERO
var last_position: = Vector2i.ZERO
var velocity: = Vector2i.ZERO
var focused: = false

func _ready() -> void:
	# Set the anchor mode to "Fixed top-left"
	# Easier to work with since it corresponds to the window coordinates
	_Camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT

	transient = true # Make the window considered as a child of the main window
	close_requested.connect(queue_free) # Actually close the window when clicking the close button

func _process(delta: float) -> void:
	velocity = position - last_position
	last_position = position
	_Camera.position = get_camera_pos_from_window()

func get_camera_pos_from_window()->Vector2i:
	return (position + velocity - world_offset) / Vector2i(_Camera.zoom)
