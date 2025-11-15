extends Node3D
class_name DungeonRoom

enum DoorState { LOCKED, CLOSED, OPEN }

@export_category("Door config")
@export var disabled_door_scene: PackedScene = null
@export var door_scene: PackedScene = null
@export var enabled_doors: Array[String] = []

@onready var door_locs = $DoorLocations

var door_nodes: Dictionary = {}

func _ready() -> void:
	pass
	#for door_name in enabled_doors:
		#if door_locs.has_node(door_name):
			#var door_location: Node3D = door_locs.get_node(door_name)
			#var disabled_door: Node3D = disabled_door_scene.instantiate()
			#disabled_door.position = door_location.position
			#disabled_door.scale = Vector3(2,2,2) # NOTE: temp, re-export in blender
			#add_child(disabled_door)
		#else:
			#push_warning("[Room] Door \"" + door_name + "\" doesn't exist.")
	
func _physics_process(delta: float) -> void:
	pass
