extends Node
class_name MovementProvider

@export_node_path("CharacterBody2D") var character
@onready var _Character: CharacterBody2D = get_node(character)

@export var enabled: bool = true
var provider_dir: float = 0.0
var provider_jump: bool = false

func _process(delta):
	if _Character:
		if enabled:
			_Character.dir = provider_dir
			_Character.jump = provider_jump
		else:
			_Character.dir = 0.0
			_Character.jump = false
