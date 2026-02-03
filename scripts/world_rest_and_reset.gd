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
	player_socket = $"/root/multiplayer_test_level/Player Sockets/p1_psock_adventure"
	self.thrall = player_socket.thrall
	player_socket.thrall = null
	#for child in psock.get_children():
	#	print(child.name)
	#print(psock)

	thrall.enque_action("emote_sit")
	thrall.look_at(thrall.global_position + (thrall.global_position - get_parent().global_position))
	reset()
	player_socket.headsUpDisplay.open_submenu(rest_menu)

func reset():
	reset_particles.emitting = true
	reset_sfx.play()

func get_back_up():
	print("Get back up")
	player_socket.thrall = thrall
	player_socket = null