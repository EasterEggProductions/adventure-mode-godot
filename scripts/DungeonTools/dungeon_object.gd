@tool
class_name DungeonObject
extends Node3D

signal state_update(node: DungeonObject, data: Dictionary)

@export var object_connections: Dictionary[PackedScene, String]:
	set(dict):
		print('set')

#var id: int = 0 # not used
var connected_objects: String = ""

# Called whenever a dungeon object needs to update its state, goes up to the level manager
func notify() -> void:
	emit_signal("state_update", self, serialize())

func create_connection_property():
	notify_property_list_changed()
	
func _get_property_list():
	
	return [{
			"name": "object_connections",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "test,test1,test2",
			"usage": PROPERTY_USAGE_DEFAULT
	}]

func _set(property, value):
	if property == "object_connections":
		object_connections = value
		return true
	return false

func _get(property):
	if property == "object_connections":
		return object_connections

func serialize() -> Dictionary:
	push_warning(self.name + ": serialize() is unimplemented!")
	return {}
	
func deserialize(state: Dictionary) -> void:
	push_warning(self.name + ": deserialize() is unimplemented!")
