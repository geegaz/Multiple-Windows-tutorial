extends Node

@export var player_size: Vector2i = Vector2i(32, 32) # Should be the size of your character sprite, or slightly bigger
@export_range(0, 19) var player_visibility_layer: int = 1
@export_range(0, 19) var world_visibility_layer: int = 0
@export_node_path("Camera2D") var main_camera: NodePath
@export var view_window: PackedScene

var world_offset: = Vector2i.ZERO

@onready var _MainCamera: Camera2D = get_node(main_camera)
@onready var _MainWindow: Window = get_window()
@onready var _MainScreen: int = _MainWindow.current_screen
@onready var _MainScreenRect: Rect2i = DisplayServer.screen_get_usable_rect(_MainScreen)

func _ready():
	# ------------ MAIN WINDOW SETUP ------------
	# Enable per-pixel transparency, required for transparent windows but has a performance cost
	# Can also break on some systems
	ProjectSettings.set_setting("display/window/per_pixel_transparency/allowed", true)


	# Set the window settings - most of them can be set in the project settings
	_MainWindow.borderless = true		# Hide the edges of the window
	_MainWindow.unresizable = true		# Prevent resizing the window
	_MainWindow.always_on_top = true	# Force the window always be on top of the screen
	_MainWindow.gui_embed_subwindows = false # Make subwindows actual system windows <- VERY IMPORTANT
	# display->window->transparent has to be set to true in the project setting, in IDE´s Menu "Project->Project Settings...",
	# Otherwise _MainWindow.transparent doesn't affect the player´s sprite (tested in Godot 4.2.2)
	_MainWindow.transparent = true		# Allow the window to be transparent
	# Settings that cannot be set in project settings
	_MainWindow.transparent_bg = true	# Make the window's background transparent

	# The window's size may need to be smaller than the default minimum size
	# so we have to change the minimum size BEFORE setting the window's size
	_MainWindow.min_size = player_size * Vector2i(_MainCamera.zoom)
	_MainWindow.size = _MainWindow.min_size
	# To only see the character in the main window, we need to
	# move its sprite on a separate visibility layer from the world
	# and set the main window to cull (not show) the world's visibility layer
	_MainWindow.set_canvas_cull_mask_bit(player_visibility_layer, true)
	_MainWindow.set_canvas_cull_mask_bit(world_visibility_layer, false)
	# -------------------------------------------

	# Position the world at the bottom-center of the screen
	world_offset = Vector2i(_MainScreenRect.size.x / 2, _MainScreenRect.size.y)

func _process(delta):
	# Update the main window's position
	_MainWindow.position = get_window_pos_from_camera()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		create_view_window()

	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func get_window_pos_from_camera()->Vector2i:
	return (Vector2i(_MainCamera.global_position + _MainCamera.offset) - player_size / 2) * Vector2i(_MainCamera.zoom) + world_offset

func create_view_window():
	var new_window: Window = view_window.instantiate()
	# Pass the main window's world to the new window
	# This is what makes it possible to show the same world in multiple windows
	new_window.world_2d = _MainWindow.world_2d
	new_window.world_3d = _MainWindow.world_3d
	# The new window needs to have the same world offset as the player
	new_window.world_offset = world_offset
	# Contrarily to the main window, hide the player and show the world
	new_window.set_canvas_cull_mask_bit(player_visibility_layer, false)
	new_window.set_canvas_cull_mask_bit(world_visibility_layer, true)
	add_child(new_window)
