extends Node

var playerSockets : Array[PlayerSocket] = []

var player_last_saved_pos : Transform3D

var actor_prefab_path = "prefabs/actor.tscn" #res:// omitted for ResourceLoader

func _ready() -> void:
	add_player_socket("p1_")
	ResourceLoader.load_threaded_request(actor_prefab_path)

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
	var new_player : Actor = ResourceLoader.load_threaded_get(actor_prefab_path).instantiate() 
	new_player.add_to_group("Players")
	return new_player