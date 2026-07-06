@tool
class_name ObjectConnection
extends Resource

enum ConnectionType {
	EMITTER, RECEIVER
}

@export_file("*.tscn") var scene_path: String:
	set(scene):
		scene_path = scene
		call_deferred("_update_possible_nodes")
		
var object_name: String = ""

@export var affected_properties: Dictionary[String, Variant] = {}

var _possible_nodes : Array[String] = []

# godot converts the filename given in the editor to a UID automatically, this function gives back the file name.
func get_scene_name() -> String:
	return ResourceUID.get_id_path(ResourceUID.text_to_id(scene_path))

## NOTE: All of this below was copied from exit_zone.gd, this resource could also be used for that probably

func _update_possible_nodes():
	_possible_nodes.clear()

	if scene_path == null:
		notify_property_list_changed()
		return

	var scene_instance = load(scene_path).instantiate()
	_recursive_node_search(scene_instance)
	scene_instance.free()
	notify_property_list_changed()

func _recursive_node_search(node: Node):
	if node is DungeonObject:
		_possible_nodes.append(node.name)
	for child in node.get_children():
		_recursive_node_search(child)

func _get_property_list():
	return [{
			"name": "object_name",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(_possible_nodes),
			"usage": PROPERTY_USAGE_DEFAULT
	}]

func _set(property, value):
	if property == "object_name":
		object_name = value
		return true
	return false

func _get(property):
	if property == "object_name":
		return object_name
	return null
