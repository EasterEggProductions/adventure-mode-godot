extends Node

@export var debout : RichTextLabel
@export var join_code_out : RichTextLabel

@export var jc_input : LineEdit

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	populate_debug_readout()

func _button_host():
	MgrMultiplayer._on_butt_host_pressed()


func _button_connect():
	MgrMultiplayer.apply_join_code(jc_input.text)

func _button_connect_invade():
	MgrPlayerSocket.player_type = "enemy" # set to invader type
	MgrMultiplayer.apply_join_code(jc_input.text)


func populate_debug_readout():
	var message : String = ""
	# Are we a server
	message += "Is server\n" if multiplayer.is_server() else "Is not server\n"
	# What is our local IP
	message += str(IP.get_local_addresses()) + "\n"
	# What is our local port
	# What is our UPNP status 
	message += "UPNP:\n"
	message += "		 thread: " + str(MgrMultiplayer.upnp_thread) + "\n"
	message += "		 status: " + str(MgrMultiplayer.upnp_status) + "\n"
	message += "		udp_res: " + str(MgrMultiplayer.upnp_udp_res) + "\n"
	message += "		tcp_res: " + str(MgrMultiplayer.upnp_tcp_res) + "\n"
	message += " setup complete: " + str(MgrMultiplayer.upnp_setup_complete) + "\n"
	# How many connections?
	message += "Connections: " + str(len(multiplayer.get_peers()))

	debout.text = message

	join_code_out.text = MgrMultiplayer.get_join_code()

func _on_clipboard_button_pressed() -> void:
	DisplayServer.clipboard_set(MgrMultiplayer.get_join_code())

func _on_join_local_button_pressed() -> void:
	#join local r something
	MgrMultiplayer.SRV_IP = "localhost"
	MgrMultiplayer.PORT = 33900
	MgrMultiplayer._on_butt_connect_pressed()
	MgrPlayerSocket.player_type = "ally" # set to coop type


func _on_invade_local_button_pressed() -> void:
	MgrMultiplayer.SRV_IP = "localhost"
	MgrMultiplayer.PORT = 33900
	MgrMultiplayer._on_butt_connect_pressed()
	MgrPlayerSocket.player_type = "enemy" # set to invader type