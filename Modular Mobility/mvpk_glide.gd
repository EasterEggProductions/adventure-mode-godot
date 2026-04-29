extends MovementPackage

class_name mvpk_glide

var terminalVel = -1.0


func pack_type() -> String:
	return "mvpk_glide" # godot does not support getting custom class names

func transfer_situation_check(thrall : Actor) -> bool:
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
	var root_motion_vel = ((thrall.animation_tree.get_root_motion_rotation_accumulator().inverse() * thrall.get_quaternion()) * thrall.animation_tree.get_root_motion_position() / delta) * 2

	var strongest_wind := _strongest_wind(thrall)
	if strongest_wind != Vector3.ZERO:
		thrall.velocity = root_motion_vel + strongest_wind
	else:
		thrall.velocity = root_motion_vel
		# if gliding we know we arent on the ground
		thrall.velocity.y = old_fallVel
		thrall.velocity.y -= 1 * delta
		thrall.velocity.y = clampf(thrall.velocity.y, terminalVel, -(terminalVel * 2))
	thrall.quaternion = thrall.quaternion * ((thrall.animation_tree.get_root_motion_rotation() / delta) * 10)

	thrall.move_and_slide()

func _strongest_wind(thrall : Actor) -> Vector3:
	var best := Vector3.ZERO
	var best_mag_sq := 0.0
	for col in thrall.wind_columns_inside:
		var mag_sq := col.wind_velocity.length_squared()
		if mag_sq > best_mag_sq:
			best_mag_sq = mag_sq
			best = col.wind_velocity
	return best
