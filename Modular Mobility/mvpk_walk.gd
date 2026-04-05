extends MovementPackage

class_name mvpk_walk

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func pack_type() -> String:
	return "mvpk_walk" # godot does not support getting custom class names 

func transfer_situation_check(_thrall : Actor) -> bool:
	#printerr("ERROR - Not implimented")
	return false # always return false, so other states take priority. 

func release_situation_check(_thrall : Actor) -> bool:
	return true # Always return true, so we can be a default state

func move_thrall(thrall : Actor, delta : float):
	var old_vel = thrall.velocity
	# Get the motion delta.
	thrall.velocity = ((thrall.animation_tree.get_root_motion_rotation_accumulator().inverse() * thrall.get_quaternion()) * thrall.animation_tree.get_root_motion_position() / delta) * 1

	# Add the gravity.
	if not thrall.is_on_floor():
		thrall.velocity = old_vel
	thrall.velocity.y -= gravity * delta
	thrall.quaternion = thrall.quaternion * ((thrall.animation_tree.get_root_motion_rotation() / delta) * 10)
	# Actually move thrall