extends MovementPackage

# A class to hold a specific moveset
class_name mvpk_combat

var LDT = 0.1 # last delta time, some error or something, idk
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func pack_type():
	return "mvpk_combat" # godot does not support getting custom class names 

func transfer_situation_check(thrall : Actor) -> bool:
	if thrall.r_wep.moveset == self:
		return thrall.combat_mode
	return false

func release_situation_check(thrall : Actor) -> bool:
# parameters/claymore moveset/Attack Tree/playback
	if name == "claymore moveset":
		var state_machine : AnimationNodeStateMachinePlayback = thrall.animation_tree["parameters/" + name +"/Attack Tree/playback"]
		#var my_node : AnimationNodeStateMachine = thrall.animation_tree.tree_root.get_node(name).get_node("Attack Tree")
		#print(state_machine.get_current_node())
		if state_machine.get_current_node() == "scheathe":
			#thrall.combat_mode = false
			return true
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
