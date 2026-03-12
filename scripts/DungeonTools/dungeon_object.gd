extends Node3D
class_name DungeonObject

signal state_update(node: DungeonObject, data: Dictionary)

#var id: int = 0 # not used

# Called whenever a dungeon object needs to update its state, goes up to the level manager
func notify() -> void:
	emit_signal("state_update", self, serialize())

func serialize() -> Dictionary:
	push_warning(self.name + ": serialize() is unimplemented!")
	return {}
	
func deserialize(state: Dictionary) -> void:
	push_warning(self.name + ": deserialize() is unimplemented!")
