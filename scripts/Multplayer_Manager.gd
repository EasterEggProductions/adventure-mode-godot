extends Node

const PLAYER_SCENE = preload("res://prefabs/actor.tscn")
var PORT: int = 33911 # Default port value (will be replaced if a free port is found).

var upnp = UPNP.new()
var upnp_thread = null
var upnp_status = null
var upnp_udp_res = null
var upnp_tcp_res = null
var upnp_setup_complete = false

var enet_peer = ENetMultiplayerPeer.new()
var nop= WebSocketMultiplayerPeer.new()

@export var server_menu : Control
@export var cam_gant : Node3D 
@export var cam_actu : Camera3D
@export var ip_input : LineEdit
@export var outfit_control : Control

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
	pass

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
	var external_ip = upnp.query_external_address()
	if external_ip == "":
		print("Failed to obtain external IP address.")
	else:
		print("External IP address obtained: ", external_ip)

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
	server_menu.hide()
	
	# Scans the port range for a valid port to host on.
	var found_port := find_available_port(33900, 33999)
	
	# If no port is avialble, return to the menu.
	if found_port == -1:
		print("No available port found in range 33900-33999")
		server_menu.show()
		return

	# Uses the first available port found in the scan. 
	PORT = found_port
	print("Selected hosting port: ", PORT)

	# Run port forwarding using upnp
	upnp_thread = Thread.new()
	upnp_thread.start(_upnp_setup)

	# Creates a server on the selected port.
	var err := enet_peer.create_server(PORT)
	# If the binding fails, then return to the menu.
	if err != OK:
		print("Failed to host server on port: ", PORT)
		server_menu.show()
		return
		
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)

	add_player(multiplayer.get_unique_id())
	server_menu.visible = false

func _on_butt_connect_pressed() -> void:
	var server_ip = ip_input.text
	print("Connecting IP: ", server_ip)
	# TODO Validate ip
	server_menu.hide()
	enet_peer.create_client(server_ip, PORT)
	multiplayer.multiplayer_peer = enet_peer
	server_menu.visible = false

func _start_local_only():	
	server_menu.hide()
	var new_player = PLAYER_SCENE.instantiate()
	#new_player.name = "Thrall Local Player"
	#add_child(new_player)
	print("New player: Local only")
	print("We is us!")
	get_parent().find_child("Player Sockets").find_child("p1_psock_adventure").enthrall_new_thrall(new_player)
	cam_gant.thrall = new_player
	cam_gant.cam.target_current = new_player
	cam_gant.freeze = false
	cam_gant.cam.freeze = false
	#new_player.visible = true
	#new_player.process_mode = Node.PROCESS_MODE_INHERIT
	print("Iz noed? " + str(new_player.find_child("DresserUpper")))
	outfit_control.dress_up_controller = new_player.find_child("DresserUpper")

func add_player(peer_id):
	var new_player = PLAYER_SCENE.instantiate()
	new_player.name = str(peer_id)
	add_child(new_player)
	print("New player: " + str(peer_id))
	new_player.set_multiplayer_authority(peer_id)
	if peer_id == multiplayer.get_unique_id():
		print("We is us!")
		get_parent().find_child("Player Sockets").find_child("p1_psock_adventure").enthrall_new_thrall(new_player)
		cam_gant.thrall = new_player
		cam_gant.cam.target_current = new_player
		cam_gant.freeze = false
		cam_gant.cam.freeze = false
		print("Iz noed? " + str(new_player.find_child("DresserUpper")))
		outfit_control.dress_up_controller = new_player.find_child("DresserUpper")
