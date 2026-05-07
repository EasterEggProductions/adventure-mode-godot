extends Node

## [mgr_dungeon_state.gd]
## This singleton has two roles:
## 1. manage dungeon object state for all dungeon scenes
## 2. synchronize this state between connected clients and the server

# Scene names are the index for serialized dungeon object data, stored as a dictionary of dictionaries.
# Dictonary(scene name -> Dictonary(object_name -> Dictonary))
# example: object_data["some_scene_name"]["some_object_name"]["the_property_i_want"]
var object_data: Dictionary = {}

#signal network_state_changed(scene_name: String, object_name: String, data: Dictionary)

func register_dungeon(scene_names: Array):
	for scene_name in scene_names:
		object_data[scene_name] = {}

func load_objects(scene_name: String) -> Dictionary:
	if object_data.has(scene_name):
		return object_data[scene_name]
	return {}

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

# saves a single dungeon object
func save_object(scene_name: String, object_name: String, data: Dictionary):
	# if we haven't saved anything from this scene yet, make sure to put the key there first
	if !object_data.has(scene_name):
		object_data[scene_name] = {}
	self.object_data[scene_name][object_name] = data

# Wipes all dungeon data, this can be used for when the player leaves the dungeon scene back into the overworld
func clear_scene_data() -> void:
	object_data = {}


## ---------- syncronization methods ----------
## okay so the server has the ultimate say for dungeon state.

## two cases:
## client interacts with object ---> server updates dungeon state ---> clients get state from server
## server interacts with object ---> client gets state from server

# Called by connected clients to send state updates to host
@rpc("any_peer", "reliable")
func client_update_state(scene_name: String, object_name: String, state: Dictionary) -> void:
	# ensure we are the server
	if !multiplayer.is_server():
		return
	
	save_object(scene_name, object_name, state)
	
	# send out the state update to all clients
	server_broadcast_state_change(scene_name, object_name, state)
	print(">>> Server has recieved client update: ", object_name, ", ", state)

# called by the host to send state updates to the clients
@rpc("authority", "reliable")
func client_recieve_state_update(scene_name: String, object_name: String, state: Dictionary) -> void:
	save_object(scene_name, object_name, state)
	#emit_signal("network_state_changed", scene_name, object_name, state)
	print(">>> Client has recieved server update: ", object_name, ", ", state)

func server_broadcast_state_change(scene_name: String, object_name: String, state: Dictionary):
	# send out the state update to all clients
	for peer_id in multiplayer.get_peers():
		rpc_id(peer_id, "client_recieve_state_update", scene_name, object_name, state)

# called by the host to update its own state
func server_update_state(scene_name: String, object_name: String, state: Dictionary) -> void:
	# ensure we are the swerver
	if !multiplayer.is_server():
		return
	
	save_object(scene_name, object_name, state)
	server_broadcast_state_change(scene_name, object_name, state)
	print(">>> Server has updated its own state: ", object_name, ", ", state)
