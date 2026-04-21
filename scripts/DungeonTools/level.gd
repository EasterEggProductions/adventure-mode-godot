class_name Level
extends Node3D

## Top level of the gameplay level
## Serializes things

@export var spawn_point : Spawnpoint3D
@export var exit_zone : ExitZone3D
# parent of all dungeon obejcts
@export var dungeon_objects: Node3D

var spawned_players : Array[Actor] = []
var local_player : Actor

##
func level_start():
	print("level start...")
	#var entering_player = MgrPlayerSocket.spawn_player()
	#entering_player.global_position = spawn_point.global_position

	## Spawn other connected players
	var our_id = multiplayer.get_unique_id()
	for conn in MgrMultiplayer.connection_level:
		if conn == our_id or conn == 0 or MgrMultiplayer.connection_level[conn] != MgrTransition.current_level.resource_path:
			continue
		var con_player : Actor = MgrPlayerSocket.spawn_player()
		con_player.name = "PLAYER|" + str(conn)
		con_player.set_multiplayer_authority(conn)
		con_player.get_node("actor_nametag").set_nametag_visibility(ActorNametag.VisState.ALWAYS)
		add_child(con_player)
		spawned_players.append(con_player)

	## TODO make a player spawning function or something
	var new_player : Actor = MgrPlayerSocket.spawn_player()
	add_child(new_player)
	new_player.name = "PLAYER|" + str(our_id) # NOTE Hardcoded name where part of name is used as data
	#new_player.transform = MgrPlayerSocket.player_last_saved_pos
	MgrPlayerSocket.get_player_one().ganty_thing.thrall = new_player
	MgrPlayerSocket.get_player_one().ganty_thing.cam.target_current = new_player
	MgrPlayerSocket.get_player_one().ganty_thing.freeze = false
	MgrPlayerSocket.get_player_one().ganty_thing.cam.freeze = false
	MgrPlayerSocket.get_player_one().enthrall_new_thrall(new_player)
	MgrPlayerSocket.get_player_one().cont_state = MgrPlayerSocket.get_player_one().ControlState.FULL
	new_player.set_multiplayer_authority(our_id)
	new_player.add_to_group("local_player")
	new_player.get_node("actor_nametag").set_nametag_visibility(ActorNametag.VisState.NEVER)
	spawned_players.append(new_player)
	local_player = new_player
	if MgrPlayerSocket.player_outfit:
		var dup : DresserUpper = local_player.find_child("DresserUpper")
		dup.outfit_load(MgrPlayerSocket.player_outfit)

	# find spawn point:
	if MgrTransition.target_spawn_point != "":
		var spawn = find_child(MgrTransition.target_spawn_point)
		new_player.global_transform = spawn.global_transform
		MgrTransition.target_spawn_point = ""
	else:
		new_player.global_transform = MgrPlayerSocket.player_last_saved_pos

	## Initialize all the dungeon objects, and hook up their state update signals
	if dungeon_objects:
		var data = MgrDungeonState.load_objects(self.name)
		if data == null: # Ensures the save data exists.
			data = {}
		# Load saved time_of_day from dungeon state if it exists.
		if data != null and data.has("time_of_day"):
			$DayNightCycle.set_time(data["time_of_day"])
		for object in dungeon_objects.get_children():
			if !(object is DungeonObject):
				push_warning(object.name + " is not a dungeon object.")
				continue
			# if we have a data entry, load it up
			if data != null && data.has(object.name):
				object.deserialize(data[object.name])
			object.connect("state_update", self._on_object_update)


# called when a local dungeon object has chnaged state, interact with multiplayer manager somehow
func _on_object_update(node: DungeonObject, data: Dictionary) -> void:
	print(node.name + ": " + str(data))

func save_objects():
	var data = [] if dungeon_objects == null else dungeon_objects.get_children()

	# Pack the current time_of_day into the save data so it persists between scenes.
	var extra_data = {
		"time_of_day": $DayNightCycle.time_of_day
	}
	MgrDungeonState.save_objects(self.name, data, extra_data)

func remove_player(conn_id : int):
	print(spawned_players)
	for guy in spawned_players:
		if str(conn_id) in guy.name:
			guy.queue_free()
			spawned_players.remove_at(spawned_players.find(guy))
			return
