class_name DungeonObject
extends Node3D

signal state_update(node: DungeonObject, data: Dictionary)

@export var enable_remote_state_changes: bool = false
@export var remote_connections: Array[ObjectConnection]

# Called whenever a dungeon object needs to update its state, goes up to the level manager
func notify() -> void:
	emit_signal("state_update", self, serialize())

func create_connection_property():
	notify_property_list_changed()

# abstract methods
func serialize() -> Dictionary:
	push_warning(self.name + ": serialize() is unimplemented!")
	return {}
	
func deserialize(state: Dictionary) -> void:
	push_warning(self.name + ": deserialize() is unimplemented!")
