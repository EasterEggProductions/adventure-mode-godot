extends Node

## Singleton for managing dungeon object state between scenes
## maybe expanded into broader world save system?

# Scene names are the index for serialized dungeon object data, stored as a dictionary of dictionaries.
# Dictonary(scene name -> Dictonary(object_name -> Dictonary))
# example: object_data["some_scene_name"]["some_object_name"]["the_property_i_want"]
var object_data: Dictionary = {}

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func load_objects(scene_name: String):
	if object_data.has(scene_name):
		return object_data[scene_name]
	return null

func save_objects(scene_name: String, dungeon_objects: Array, extra_data: Dictionary = {}) -> void:
	# grab all the object data
	var all_data = {}
	for object: DungeonObject in dungeon_objects:
		all_data[object.name] = object.serialize()
	
	# Added extra scene-level data into the save dictionary.
	for key in extra_data:
		all_data[key] = extra_data[key]
	# save it
	object_data[scene_name] = all_data
	#print("SAVED: ", all_data)
