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

	var motion_delta = ((thrall.animation_tree.get_root_motion_rotation_accumulator().inverse() * thrall.get_quaternion()) * thrall.animation_tree.get_root_motion_position() / delta) * 1
	thrall.velocity = motion_delta

	if not thrall.is_on_floor():# and motion_delta.y > 0:
		thrall.velocity = old_vel + (motion_delta * delta)#(0.01666 / delta)) #2.8 
		# This is awful, everything works so well for 60fps, all data coming from the animation, the animator. But no, that just won't work for some reason
		# TODO - Replace jumps with anim_physics_impulse(imp : Vector3) in the Actor class, and have jumps just be a function call track. 
		# I really dislike this, I wanted everything to just be an imported animation, not a bunch of fine tuning. It ruins the portability which is 
		# supposed to be the crux of the whole damn system! 
	thrall.velocity.y -= (gravity * delta)
	thrall.quaternion = thrall.quaternion * ((thrall.animation_tree.get_root_motion_rotation() / delta) * 10)
