extends Node

var playerSockets : Array[PlayerSocket] = []

var player_last_saved_pos : Transform3D


func _ready() -> void:
	add_player_socket("p1_")

func add_player_socket(prefix : String):
	var player = PlayerSocket.new()
	player.name = prefix + "psock_adventure"
	player.player_prefix = prefix
	player.target_locker = preload("res://art/Props/z_target.tscn")
	add_child(player)
	playerSockets.append(player)

func get_player_one() -> PlayerSocket:
	return playerSockets[0]

func spawn_player() -> Actor:
	var new_player : Actor = preload("res://prefabs/actor.tscn").instantiate() 
	get_tree().current_scene.add_child(new_player)
	new_player.transform = player_last_saved_pos
	new_player.add_to_group("Players")
	# mainCam
	#playerSockets[0].ganty_thing.thrall = new_player
	#playerSockets[0].ganty_thing.cam.target_current = new_player
	#playerSockets[0].ganty_thing.freeze = false
	#playerSockets[0].ganty_thing.cam.freeze = false
	#playerSockets[0].enthrall_new_thrall(new_player)
	return new_player