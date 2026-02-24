extends Node3D
class_name Level

## Top level of the gameplay level
## Serializes things 

@export var spawn_point : Node3D 
@export var exit_zone : Area3D

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
    new_player.set_multiplayer_authority(our_id)
    new_player.add_to_group("local_player")
    spawned_players.append(new_player)
    local_player = new_player

    # find spawn point:
    if MgrTransition.target_spawn_point != "":
        var spawn = find_child(MgrTransition.target_spawn_point)
        new_player.global_transform = spawn.global_transform
        MgrTransition.target_spawn_point = ""
    else: 
        new_player.global_transform = MgrPlayerSocket.player_last_saved_pos

## For despawning players and cleaning up before going to another level. 
func level_exit():
    pass

func remove_player(conn_id : int):
    print(spawned_players)
    for guy in spawned_players:
        if str(conn_id) in guy.name:
            guy.queue_free()
            spawned_players.remove_at(spawned_players.find(guy))
            return
