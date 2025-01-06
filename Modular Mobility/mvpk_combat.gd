extends MovementPackage

# A class to hold a specific moveset
class_name mvpk_combat

var LDT = 0.1 # last delta time, some error or something, idk
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func transfer_situation_check(thrall : Actor) -> bool:
	return thrall.combat_mode

func release_situation_check(thrall : Actor) -> bool:
	return !thrall.combat_mode


func move_thrall(thrall : Actor, delta : float):
	var old_vel = thrall.velocity
	# Get the motion delta.
	thrall.velocity = ((thrall.animation_tree.get_root_motion_rotation_accumulator().inverse() * thrall.get_quaternion()) * thrall.animation_tree.get_root_motion_position() / delta) 

	# Add the gravity.
	if not thrall.is_on_floor():# && thrall.desired_move.y < 0.1:
		thrall.velocity = old_vel
	thrall.velocity.y -= gravity * delta
	thrall.quaternion = thrall.quaternion * ((thrall.animation_tree.get_root_motion_rotation() / delta) * 10)
	# Actually move thrall
	thrall.move_and_slide()
