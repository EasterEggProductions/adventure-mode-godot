extends Node3D
class_name DungeonObject

signal state_update(node: DungeonObject, data: Dictionary)

func notify() -> void:
	emit_signal("state_update", self, serialize())

func serialize() -> Dictionary:
	push_warning(self.name + ": serialize() is unimplemented!")
	return {}
