@tool
@icon("res://art/textures/icons/icon_exit_zone.svg")
class_name ExitZone3D
extends Area3D

## The resource path is required to prevent cyclic dependencies
@export_file("*.tscn")
var scene_to_go_to : String:
	set(scene):
		scene_to_go_to = scene
		call_deferred("_update_possible_nodes") ## Prevents godot from exploding!

## Name of the node spawn point
var spawn_point : String = ""

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

## Custom Editor Property Handling
var _possible_nodes : Array[String] = []

func _update_possible_nodes():
	_possible_nodes.clear()

	if scene_to_go_to == null:
		notify_property_list_changed()
		return

	var scene_instance = load(scene_to_go_to).instantiate()
	_recursive_node_search(scene_instance)

	scene_instance.free()
	notify_property_list_changed()

func _recursive_node_search(node: Node):
	if node is Spawnpoint3D:
		_possible_nodes.append(node.name)
	for child in node.get_children():
		_recursive_node_search(child)

func _get_property_list():
	return [{
			"name": "spawn_point",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(_possible_nodes),
			"usage": PROPERTY_USAGE_DEFAULT
	}]

func _set(property, value):
	if property == "spawn_point":
		spawn_point = value
		return true
	return false

func _get(property):
	if property == "spawn_point":
		return spawn_point
