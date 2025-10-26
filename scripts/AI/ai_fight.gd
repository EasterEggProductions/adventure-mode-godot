extends Node
# NOTE - thralling methods do not check of establis que at this time
@export var player : Actor # Just one player right now, easy mode
@onready var thrall = get_parent() as Actor

@export var dist_see = 10
@export var dist_attack = 5

var goTo : Vector3


var timer = 0.0


enum ATT_STATE {IDLE, RETREATING, ATTACKING, DODGING}
var state = ATT_STATE.IDLE

var start_pos

@export var action = false
var dist



# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = thrall.global_position
	goTo = find_somewhere_to_go()
	thrall.hand_state = Actor.HandState.TWO_HAND
	thrall.enque_action("attack_light")
	move_fix()

func move_fix():
	await get_tree().create_timer(2).timeout
	thrall.enque_action("dodge")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#patrol(delta)
	#return
	if multiplayer.is_server() == false:
		return
	if is_instance_valid(thrall) and thrall.alive == false:
		return
	timer -= delta

	if get_tree().get_nodes_in_group("players").size() == 0:
		return
	if is_instance_valid(player) == false:
		for play in get_tree().get_nodes_in_group("players"):
			if play is Actor and play.alive == true:
				player = play
				break
		return # find player, just come back next frame with a valid player instance	
	dist = thrall.global_position.distance_to(player.global_position)
	if dist <= dist_attack:
		in_attack_range(delta)
	elif dist <= dist_see:
		in_spot_range(delta)
	elif timer <= 0:
		goTo = start_pos
		goTo.y = thrall.global_position.y
		var go_d = (goTo - thrall.global_position).normalized()
		var transformed_move_dir =  Vector2(( thrall.global_basis.inverse() * -go_d).x,-( thrall.global_basis.inverse() * -go_d).z)
		thrall.desired_turn = transformed_move_dir.x

		
	var go_dir = goTo - thrall.global_position
	thrall.handle_movement(go_dir)


func patrol(delta):
	timer -= delta
	if timer <= 0:
		goTo = find_somewhere_to_go()
		goTo.y = thrall.global_position.y
		timer = 10 + float(randi_range(-1,5))
	elif goTo.distance_to(thrall.global_position) > 0.5:
		var go_dir = (goTo - thrall.global_position).normalized() * 0.5
		#var go_d = (player.global_position - thrall.global_position).normalized()
		var transformed_move_dir =  Vector2(( thrall.global_basis.inverse() * -go_dir).x,-( thrall.global_basis.inverse() * -go_dir).z)
		thrall.desired_turn = transformed_move_dir.x
		thrall.handle_movement(go_dir)
	else:
		thrall.desired_turn = 0
		var go_dir = (goTo - thrall.global_position).normalized() * 0.1		
		thrall.handle_movement(go_dir)


func find_somewhere_to_go() -> Vector3:
	return start_pos + Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))


func in_spot_range(_delta):
	thrall.combat_mode = true
	thrall.combat_relax_timer = 4.0
	var go_d = (player.global_position - thrall.global_position).normalized()
	var transformed_move_dir =  Vector2(( thrall.global_basis.inverse() * -go_d).x,-( thrall.global_basis.inverse() * -go_d).z)
	thrall.desired_turn = transformed_move_dir.x
	state = ATT_STATE.IDLE
	
func in_attack_range(_delta):
	thrall.combat_mode = true
	thrall.combat_relax_timer = 4.0

	var go_d = (player.global_position - thrall.global_position).normalized()
	var transformed_move_dir =  Vector2(( thrall.global_basis.inverse() * -go_d).x,-( thrall.global_basis.inverse() * -go_d).z)
	thrall.desired_turn = transformed_move_dir.x

	match state:
		ATT_STATE.RETREATING:
			retreating()
			return
		ATT_STATE.DODGING:
			dodging()
			return
		ATT_STATE.ATTACKING:
			attacking()
			return
		_:
			state = ATT_STATE.DODGING


func attacking():
	#print("ATTACK")
	# Move towards player, if in some range hold attack
	if dist < 2.0 && timer > 1:
		var randAct = randf()
		if randAct < 0.3:
			thrall.enque_action("attack_light")
		elif randAct < 0.4:
			thrall.enque_action("attack_heavy")
	goTo = player.global_position
	if timer <= 0:
		if randf() < 0.5:
			state = ATT_STATE.DODGING
			timer = 4.0
		else:
			state = ATT_STATE.RETREATING
			timer = 3.0

func retreating():
	#print("RETREAT")
	# move away from player + some random side to side offset
	thrall.enque_action("block")
	goTo = thrall.global_position + ((thrall.global_position - player.global_position).normalized() * 2)
	if timer <= 0:
		if randf() < 0.5:
			state = ATT_STATE.DODGING
			timer = 4.0
		else:
			state = ATT_STATE.ATTACKING
			timer = 4.0

func dodging():
	#print("DODGE!")
	# move near player strafe around them
	thrall.dodge = true
	goTo = thrall.global_position + thrall.global_basis.x
	var randAct = randf()
	if randAct < 0.05:
		thrall.enque_action("dodge")
	if randAct < 0.1:
		goTo = thrall.global_position
		thrall.enque_action("dodge")
	if timer <= 0:
		if randf() < 0.5:
			state = ATT_STATE.ATTACKING
			timer = 4.0
		else:
			state = ATT_STATE.RETREATING
			timer = 3.0



func create_arrow_mesh() -> ArrayMesh:
	var arrow_mesh = ArrayMesh.new()

	# Create a cylinder for the arrow shaft
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.05
	cylinder.bottom_radius = 0.05
	cylinder.height = 0.6
	var cylinder_transform = Transform3D(Basis(), Vector3(0, 0.3, 0))  # Move up so base is at origin

	# Add the cylinder mesh to the ArrayMesh
	arrow_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, cylinder.surface_get_arrays(0))
	arrow_mesh.surface_transform(0, cylinder_transform)

	# Create a cone for the arrowhead
	var cone = CylinderMesh.new()
	cone.top_radius = 0.01
	cone.bottom_radius = 0.2
	cone.height = 0.3

	# Add the cone mesh to the ArrayMesh
	arrow_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, cone.surface_get_arrays(0))
	#arrow_mesh.surface_transform(1, cone_transform)

	return arrow_mesh
