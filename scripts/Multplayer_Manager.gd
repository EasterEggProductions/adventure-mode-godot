extends Node

const PLAYER_SCENE = preload("res://prefabs/actor.tscn")
const PORT = 8080
var enet_peer = ENetMultiplayerPeer.new()
var nop= WebSocketMultiplayerPeer.new()

@export var server_menu : Control
@export var cam_gant : Node3D 
@export var cam_actu : Camera3D
@export var ip_input : LineEdit
@export var outfit_control : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#get_ping.rpc_id()
	pass

func _on_butt_host_pressed() -> void:
	if OS.get_name() == "Web":
		print("Web build detected, quick, change everything about networking so it all breaks, quickly everyone!")
		_start_local_only()
	server_menu.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)

	add_player(multiplayer.get_unique_id())
	server_menu.visible = false

func _on_butt_connect_pressed() -> void:
	var server_ip = ip_input.text
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

@rpc("any_peer")
func get_ping(peer_id):
	# if we are the server, wait for packet
	if multiplayer.is_server():
		print("starting ping check")
		get_ping.rpc(peer_id)
	# if we are a client, send the packet
	else:
		print("we gotta ping check")
		var t1 = Time.get_unix_time_from_system
		var sender_id = multiplayer.get_remote_sender_id()
		print_ping.rpc(sender_id, {"Time": t1})

@rpc("any_peer")
func print_ping(msg):
	print("Ping: " + str(Time.get_unix_time_from_system - msg["Time"]))
		
	

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
	else:
		print("interloper")
		get_ping(peer_id)
		
