extends Node

var playerSockets : Array[PlayerSocket] = []

var player_last_saved_pos : Transform3D

var player_outfit : PackedStringArray

var player_type = "main" #just using strings for debug at this moment, main, ally, enemy are all for now

var actor_prefab : PackedScene

# here temporarily
var ally_material : Material = preload("res://art/materials/cooperator.tres")
var enemy_material : Material = preload("res://art/materials/invader.tres")


func _ready() -> void:
	add_player_socket("p1_")
	actor_prefab = load("res://prefabs/actor.tscn")

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
	#print("A player actor was requested for " + str(multiplayer.get_unique_id()))
	#print_stack()
	var new_player : Actor = actor_prefab.instantiate() 
	new_player.add_to_group("Players")
	return new_player
