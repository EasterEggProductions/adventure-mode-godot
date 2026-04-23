extends Node

const PLAYER_SCENE = preload("res://prefabs/actor.tscn")
var SRV_IP: String = "localhost"
var EXT_IP: String = ""
var PORT: int = 33911 # Default port value (will be replaced if a free port is found).

var upnp = UPNP.new()
var upnp_thread = null
var upnp_status = null
var upnp_udp_res = null
var upnp_tcp_res = null
var upnp_setup_complete = false

#generic peer var, needs to be dynamic to switch between steam and Enet
var dynamic_peer
#var enet_peer = ENetMultiplayerPeer.new()
var nop= WebSocketMultiplayerPeer.new()

@export_enum("Steam", "Enet") var network_mode : String = "Enet"
@export var server_menu : Control
@export var cam_gant : Node3D 
@export var cam_actu : Camera3D
@export var ip_input : LineEdit
@export var outfit_control : Control

## What map each connection is on
var connection_level : Dictionary[int, String] = {0:""}

# Attempts to find an available port by trying to create a temp ENet server.
func find_available_port(start_port: int, end_port: int) -> int:
	for p in range(start_port, end_port + 1):
		var test_peer := ENetMultiplayerPeer.new()
		var result := test_peer.create_server(p) # Tests the binding to this port.
		test_peer.close() # Releases the test server.
		
		# If the server creation succeeded, then this port is free. 
		if result == OK:
			return p
	
	# No ports in the range were available.
	return -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Handle changes from UPNP thread once they are complete
	if upnp_setup_complete:
		_on_upnp_completed()
		# Reset so it isn't called multiple times
		upnp_setup_complete = false

# Establishes port mappings on host session creation
func _upnp_setup():
	var err = upnp.discover()
	upnp_status = err

	if err == OK and upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		# Create mappings for both UDP and TCP transimssion
		upnp_udp_res = upnp.add_port_mapping(PORT, PORT, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp_tcp_res = upnp.add_port_mapping(PORT, PORT, ProjectSettings.get_setting("application/config/name"), "TCP")

	upnp_setup_complete = true

# Prints and verifies success of port mapping and thread creation, prints external host ip for testing
func _on_upnp_completed():
	if upnp_status != OK:
		print("UPNP discovery failed with error: ", upnp_status)
		return

	# Check if port mapping was successful
	if upnp_udp_res == UPNP.UPNP_RESULT_SUCCESS:
		print("UDP port mapped successfully on port: ", PORT)
	else:
		print("Failure to add UDP mapping on port: ", PORT)

	if upnp_tcp_res == UPNP.UPNP_RESULT_SUCCESS:
		print("TCP port mapped successfully on port: ", PORT)
	else:
		print("Failure to add TCP mapping on port: ", PORT)

	# Output host ip for testing
	EXT_IP = upnp.query_external_address()
	if EXT_IP == "":
		print("Failed to obtain external IP address.")
	else:
		print("External IP address obtained: ", EXT_IP)

	# Close upnp thread
	if upnp_thread != null:
		upnp_thread.wait_to_finish()
		upnp_thread = null

# Called when node is freed or removed, we should externally call this on application quit (currently doesn't run)
func _exit_tree():
	var delete_udp = upnp.delete_port_mapping(PORT, "UDP")
	if delete_udp == UPNP.UPNP_RESULT_SUCCESS:
		print("UDP port mapping successfully removed on port: ", PORT)
	else:
		print("Failure to remove UDP mapping on port: ", PORT)
	
	var delete_tcp = upnp.delete_port_mapping(PORT, "TCP")
	if delete_tcp == UPNP.UPNP_RESULT_SUCCESS:
		print("TCP port mapping successfully removed on port: ", PORT)
	else:
		print("Failure to remove TCP mapping on port: ", PORT)
	
	if upnp_thread != null:
		upnp_thread.wait_to_finish()
		upnp_thread = null

func _on_butt_host_pressed() -> void:
	if OS.get_name() == "Web":
		print("Web build detected, quick, change everything about networking so it all breaks, quickly everyone!")
		_start_local_only()
	#server_menu.hide()
	
	# Scans the port range for a valid port to host on.
	var found_port := find_available_port(33900, 33999)
	
	# If no port is avialble, return to the menu.
	if found_port == -1:
		print("No available port found in range 33900-33999")
		#server_menu.show()
		return

	# Uses the first available port found in the scan. 
	PORT = found_port
	print("Selected hosting port: ", PORT)

	# Run port forwarding using upnp
	upnp_thread = Thread.new()
	upnp_thread.start(_upnp_setup)

	if network_mode == "Enet":
		dynamic_peer = ENetMultiplayerPeer.new()
		# Creates a server on the selected port.
		if dynamic_peer.create_server(PORT) != OK:
			# If the binding fails, then return to the menu.
			print("Failed to host server on port: ", PORT)
			server_menu.show()
			return
		multiplayer.multiplayer_peer = dynamic_peer
		multiplayer.peer_connected.connect(add_player)
		#add_player(multiplayer.get_unique_id())
	elif network_mode == "Steam":
		#dynamic_peer = SteamMultiplayerPeer.new()
		#^requires steam plugin, also need separate handling for steam lobby creation
		print("Steam plugin not found")
	
	#server_menu.visible = false

func _on_butt_connect_pressed() -> void:
	MgrTransition.msg_small("Attempting to join world", 5)
	print("Connecting IP: ", SRV_IP)
	# TODO Validate ip
	#server_menu.hide()
	if network_mode == "Enet":
		dynamic_peer = ENetMultiplayerPeer.new()
		dynamic_peer.create_client(SRV_IP, PORT)
		
	elif network_mode == "Steam":
		print("Steam plugin not found")
		## TODO Found the steam plugin
	
	multiplayer.multiplayer_peer = dynamic_peer
	#server_menu.visible = false

func _start_local_only():	
	#server_menu.hide()
	var new_player = PLAYER_SCENE.instantiate()
	#new_player.name = "Thrall Local Player"
	#add_child(new_player)
	print("New player: Local only")
	print("We is us!")
	MgrPlayerSocket.get_player_one().enthrall_new_thrall(new_player)
	cam_gant.thrall = new_player
	cam_gant.cam.target_current = new_player
	cam_gant.freeze = false
	cam_gant.cam.freeze = false
	#new_player.visible = true
	#new_player.process_mode = Node.PROCESS_MODE_INHERIT
	print("Iz noed? " + str(new_player.find_child("DresserUpper")))
	outfit_control.dress_up_controller = new_player.find_child("DresserUpper")

func add_player_OLD(peer_id):
	print("%d:Add player" % multiplayer.get_unique_id())
	connection_level[peer_id] = ""
	var new_player : Actor
	if peer_id == multiplayer.get_unique_id():
		new_player = MgrPlayerSocket.spawn_player()
		get_tree().current_scene.add_child(new_player)
		new_player.name = "PLAYER|" + str(peer_id)
		#new_player.transform = MgrPlayerSocket.player_last_saved_pos
		print("We is us!")
		MgrPlayerSocket.get_player_one().enthrall_new_thrall(new_player)
		#cam_gant.thrall = new_player
		#cam_gant.cam.target_current = new_player
		#cam_gant.freeze = false
		#cam_gant.cam.freeze = false
		MgrPlayerSocket.get_player_one().ganty_thing.thrall = new_player
		MgrPlayerSocket.get_player_one().ganty_thing.cam.target_current = new_player
		MgrPlayerSocket.get_player_one().ganty_thing.freeze = false
		MgrPlayerSocket.get_player_one().ganty_thing.cam.freeze = false
		MgrPlayerSocket.get_player_one().enthrall_new_thrall(new_player)
		#outfit_control.dress_up_controller = new_player.find_child("DresserUpper")
		new_player.add_to_group("local_player")
	else:
		new_player = PLAYER_SCENE.instantiate()
		new_player.name = "PLAYER|" + str(peer_id)
		get_tree().current_scene.add_child(new_player)
		new_player.add_to_group("Players") # NOTE: added for easy player checks in dungeon tools
		print("New player: " + str(peer_id))
	print("P join: " + str(peer_id) + ", me: " + str(multiplayer.get_unique_id()))

	new_player.set_multiplayer_authority(peer_id)
	take_guy.rpc("PLAYER|" + str(peer_id), peer_id)

func add_player(peer_id : int):
	print("%d:Add player" % multiplayer.get_unique_id())
	bring_player_in_to_the_game_or_something.rpc_id(peer_id, connection_level, MgrTransition.current_level.resource_path, "spawn_1")

@rpc
func bring_player_in_to_the_game_or_something(everyonealreadyhereandwheretheyare : Dictionary, your_start_level : String, your_spawn_point : String):
	connection_level = everyonealreadyhereandwheretheyare
	MgrTransition.level_transition(your_start_level, your_spawn_point)


func get_join_code() -> String:
	if upnp_status == 0 and upnp_udp_res == 0 and upnp_tcp_res == 0:
		return JoinCode.ip_to_code(EXT_IP, PORT)
	elif upnp_thread == null:
		return "go online to create code"
	else:
		return "generating join code..."

func apply_join_code(jc : String):
	var dat = JoinCode.code_to_ip(jc)
	SRV_IP = dat[0]
	PORT = dat[1]
	_on_butt_connect_pressed()


func _on_player_connected(_my_id : int):
	print(str(multiplayer.get_unique_id()) + " called _on_player_connected: " + str(_my_id))

func _on_player_disconnected():
	print(str(multiplayer.get_unique_id()) + " called _on_player_disconnected")

func _on_connected_ok():

	MgrTransition.msg_small("Welcome to world as a guest", 5)
	print(str(multiplayer.get_unique_id()) + " called _on_connected_ok")
	#connection_level[multiplayer.get_unique_id()] = MgrTransition.current_level.resource_path
	#for child in get_tree().current_scene.get_children():
	#	print(child.name)
	#var my_thrall = get_tree().current_scene.find_child(str(multiplayer.get_unique_id()))
	#print(my_thrall)

func _on_connected_fail():
	MgrTransition.msg_small("Connection Failed", 3)
	print(str(multiplayer.get_unique_id()) + " called _on_connected_fail")

func _on_server_disconnected():
	MgrTransition.msg_small("Connection to this world lost, returning home...", 5)
	print(str(multiplayer.get_unique_id()) + " called _on_server_disconnected")
	MgrTransition.target_spawn_point = ''
	MgrTransition.change_scene_to_pack(preload("res://scenes/title_scene.tscn")) 
	# did not want to use level_transition, to let it grow to have other functionality

@rpc
func take_guy(nodename : String, peer_id : int):
	var my_thrall = get_tree().current_scene.find_child(nodename, false, false)
	print("This my guy? " + str(my_thrall))
	#my_thrall.set_multiplayer_authority(peer_id)
	if multiplayer.get_unique_id() == peer_id:
		MgrPlayerSocket.get_player_one().ganty_thing.thrall = my_thrall
		MgrPlayerSocket.get_player_one().ganty_thing.cam.target_current = my_thrall
		MgrPlayerSocket.get_player_one().ganty_thing.freeze = false
		MgrPlayerSocket.get_player_one().ganty_thing.cam.freeze = false
		MgrPlayerSocket.get_player_one().enthrall_new_thrall(my_thrall)
	

func inform_of_level_change(levelname : String):
	# TODO check to see if multiplayer is even running
	net_change_level.rpc(levelname, multiplayer.get_unique_id())
	connection_level[multiplayer.get_unique_id()] = levelname
	# If we are coming in to a level, we need to spawn that player!


@rpc("any_peer")
func net_change_level(levelname : String, peer_id : int):
	print("Player %s has switched to level %s" % [str(peer_id), levelname])
	# If this player is changing from the level we are in, we need to despawn them
	if connection_level.has(peer_id) and connection_level[peer_id] == connection_level[multiplayer.get_unique_id()]:		
		MgrTransition.msg_small("Player %s has left to %s" % [str(peer_id), levelname], 7)
		get_tree().current_scene.remove_player(peer_id)
	elif levelname == connection_level[multiplayer.get_unique_id()]:
		MgrTransition.msg_small("Player %s has joined you in %s" % [str(peer_id), levelname], 7)
		spawn_me_in_coach(peer_id)
	else:
		MgrTransition.msg_small("Player %s has moved about levels..." % str(peer_id), 7)
	connection_level[peer_id] = levelname

func visibility_filter(connection : int) -> bool:
	if connection_level.has(connection):
		var our_level = connection_level[multiplayer.get_unique_id()]
		var their_level = connection_level[connection]
		return our_level == their_level	
	return true

func TEST_SPAWN_REMOTE(connection : int) -> void:
	print("remote spawning a guy")
	spawn_me_in_coach.rpc_id(1, connection) 

@rpc("any_peer")
func spawn_me_in_coach(connection : int) -> void:
	var new_player : Actor = MgrPlayerSocket.spawn_player()
	new_player.name = "PLAYER|" + str(connection)
	#new_player.set_multiplayer_authority(connection)
	get_tree().current_scene.add_child(new_player)
	##await get_tree().create_timer(10).timeout
	print("New guy path: "+ str(new_player.get_path()))
	new_player.get_node("actor_nametag").set_nametag_visibility(ActorNametag.VisState.ALWAYS) # NOTE This function will probably handle enemy player spawning and those need different visibility
	get_tree().current_scene.spawned_players.append(new_player)
	#take_guy.rpc(bute, connection)
