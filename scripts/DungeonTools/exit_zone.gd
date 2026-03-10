extends Area3D

## The resource path is required to prevent cyclic dependencies
@export var scene_to_go_to : String

## Name of the node spawn point
@export var spawn_point : String

@onready var _level_scene = get_tree().current_scene

func _ready() -> void:
	start_delay()

func _start_level_transition(body : Node3D):	
	if body.is_in_group("local_player"):
		print("Going to level %s at entry %s" % [scene_to_go_to, spawn_point])
		# Save the data for all dungeon objects
		_level_scene.save_objects() # NOTE: too much indirection maybe replace with signal
		# then do the transition
		MgrTransition.level_transition(scene_to_go_to, spawn_point)

func start_delay():
	await get_tree().create_timer(2).timeout
	monitoring = true
	monitorable = true
