extends MovementPackage

class_name mvpk_glide

var termnalVel = -1.0

func transfer_situation_check(thrall : Actor) -> bool:
#	printerr("ERROR - Not implimented")

	if thrall.is_on_floor() == false:
		if Input.is_action_just_pressed("p1_jump"):
			thrall.combat_mode = false
			return true
	return false

func release_situation_check(thrall : Actor) -> bool:	
	if thrall.is_on_floor() or Input.is_action_just_pressed("p1_crouch"):
		return true
	return false

func move_thrall(thrall : Actor, delta : float):	
	var old_fallVel = thrall.velocity.y
	# Get the motion delta.
	thrall.velocity = ((thrall.animation_tree.get_root_motion_rotation_accumulator().inverse() * thrall.get_quaternion()) * thrall.animation_tree.get_root_motion_position() / delta) * 2

	# if gliding we know we arent on the ground
	thrall.velocity.y = old_fallVel # + velocity.y
	thrall.velocity.y -= 1 * delta
	thrall.velocity.y = clampf(thrall.velocity.y, termnalVel, -(termnalVel * 2))
	thrall.quaternion = thrall.quaternion * ((thrall.animation_tree.get_root_motion_rotation() / delta) * 10)

	thrall.move_and_slide()