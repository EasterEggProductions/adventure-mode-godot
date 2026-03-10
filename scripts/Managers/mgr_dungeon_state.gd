extends Node

## Singleton for managing dungeon object state between scenes
## maybe expanded into broader world save system?

# Scene names are the index for serialized dungeon object data
# (scene name) -> Array[Dictonary], where index is dungeon object ID
var object_data: Dictionary = {}

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func load_objects(scene_name: String):
	if object_data.has(scene_name):
		return object_data[scene_name]
	return null

func save_objects(scene_name: String, dungeon_objects: Array) -> void:
	# grab all the object data
	var data = []
	for node in dungeon_objects:
		data.append(node.serialize())
	# save it
	object_data[scene_name] = data
	print("SAVED: ", data)
