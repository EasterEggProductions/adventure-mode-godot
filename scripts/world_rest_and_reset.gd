extends Node

@export var reset_particles : GPUParticles3D
@export var reset_sfx : AudioStreamPlayer3D
@export var rest_menu : PackedScene

var player_socket
var thrall

func _process(delta: float) -> void:
	if player_socket != null && is_instance_valid(player_socket.headsUpDisplay.child_menu) == false:
		get_back_up()

func rest(thrall : Actor):
	# NOTE - A bit of a hack to get it working for now
	player_socket = MgrPlayerSocket.get_player_one()
	self.thrall = player_socket.thrall
	player_socket.cont_state = player_socket.ControlState.NONE
	#for child in psock.get_children():
	#	print(child.name)
	#print(psock)

	thrall.enque_action("emote_sit")
	var look_pos = thrall.global_position + (thrall.global_position - get_parent().global_position)
	look_pos.y = thrall.global_position.y
	thrall.look_at(look_pos)
	reset()
	player_socket.headsUpDisplay.open_submenu(rest_menu)

func reset():
	reset_particles.emitting = true
	reset_sfx.play()

func get_back_up():
	#print("Get back up")
	player_socket.cont_state = player_socket.ControlState.FULL
	player_socket = null