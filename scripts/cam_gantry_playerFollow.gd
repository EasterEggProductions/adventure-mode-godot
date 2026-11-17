extends Node3D

var follow_height_offset = 1.0
var cam_follow_dist = 2.5
var cam_current_dist = 2.5 # distance camera actually is, shrinks near walls
@export var thrall : Actor
@export var cam : Camera3D

@export var freeze = false
@export var show_debug_rays = false # draws the line-of-sight rays and box points in game, see draw_debug_points for what the colors mean

var velocity = Vector3.ZERO

var look_rotation_vel = Vector2.ZERO
var camLookAccell = 3.14
var camTimer = 0.0

# --- line-of-sight box ---
# a few points around the player (knees, elbows, head). if a wall gets between one of those points
# and the camera, the gantry swings or tilts until the whole box is visible again, same as if you'd
# moved the camera yourself. heights are measured up from the player's feet, sideways is screen
# left/right (not the character's left/right) so the box doesn't spin around when the player turns
const KNEE_HEIGHT = 0.3
const KNEE_SIDE = 0.1
const ELBOW_HEIGHT = 1.1
const ELBOW_SIDE = 0.5
const HEAD_TOP_HEIGHT = 1.85
const HEAD_SIDE_HEIGHT = 1.6
const HEAD_SIDE = 0.15
const POINT_WALL_GAP = 0.05 # if a point would poke into a wall it gets pulled back to this far in front of it

const SWING_START_SPEED = 60.0 # degrees per second a sideways swing starts at
const SWING_TOP_SPEED = 180.0 # it speeds up to this the longer part of the box stays hidden
const SWING_SPEED_UP = 120.0 # how much faster it gets each second it stays hidden (60 -> 180 takes 1 s)
const SWING_MAX_TURN = 180.0 # most one swing can turn the cam before it gives up
const SWING_LOOK_AHEAD = 45.0 # when the whole player's hidden and no swing is going, test this far each way to pick a side
const TILT_SPEED = 60.0 # degrees per second the gantry tilts the cam up while the knees or head top are hidden
const PUSH_EXTRA = 0.25 # once everything shows up again keep going this many meters, so the cam really clears the wall
const LAST_RESORT_WAIT = 0.25 # seconds the box has to sit still before the head jump or the pivot snap can kick in
const INPUT_STOPPED_AFTER = 0.1 # seconds with no mouse or stick movement before we count it as you letting go of the camera
const WALK_TO_RESUME_SPEED = 0.5 # after you move the camera yourself, the box stays off until the player moves faster than this (m/s)
const WALL_MARGIN = 0.2 # how far the cam stays off walls and ceilings, same as the pivot ray

var swing_direction = 0.0 # which way the current swing goes, +1 = cam swings screen right, -1 = screen left, 0 = no swing going
var swing_speed = SWING_START_SPEED # how fast the current swing is turning, ramps up while the box stays hidden
var swing_turned_so_far = 0.0 # degrees the current swing has turned, so it can't spin around forever
var swing_extra_left = 0.0 # meters of extra swing still to do after the sides came back into view
var tilt_extra_left = 0.0 # same thing for the tilt
var swinging = false # true on frames where the swing actually turned the cam, the tilt waits while it's true
var time_since_box_moved = 999.0 # seconds since the swing or tilt last turned the cam, the last resorts wait on this
var box_paused = false # true after you move the camera yourself, the box stays off until the player walks again
var time_since_camera_input = 999.0 # seconds since the mouse or right stick last moved the camera
var actors_to_ignore : Array[RID] = [] # every actor's body, rebuilt at the top of each frame and skipped by every camera ray

# --- wobble fix ---
# how much of the player's own speed the gantry copies. 1.0 = keeps right up with the player,
# lower it (like 0.7) to get some of the old floaty lag back
const FOLLOW_MATCH = 1.0

# --- debug drawing ---
var debug_lines = [] # every ray we fired this frame, gets drawn if show_debug_rays is on
var debug_mesh : ImmediateMesh
var debug_mesh_instance : MeshInstance3D
var debug_box_points = [] # the 7 box points from this frame, so the markers know where to sit
var debug_box_pulled = [] # true for each point that got pulled out of a wall this frame
var debug_point_markers = [] # one little sphere per box point, made the first time debug gets turned on
var debug_clear_material : StandardMaterial3D # green, the cam can see this point right now
var debug_hidden_material : StandardMaterial3D # red, a wall is hiding this point from the cam right now
var debug_pulled_material : StandardMaterial3D # yellow, this point would've been inside a wall so it got pulled out

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MgrPlayerSocket.get_player_one().ganty_thing = self
	#this should keep mouse within boarders, need to capture escape button so user can interact with menu (to leave) 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


#also changed _physics_process to process here for jitter fix
func _process(delta: float) -> void:
	if thrall == null:
		return
	debug_lines.clear() # fresh frame, fresh set of debug rays
	actors_to_ignore = build_actor_ignore_list() # every camera ray this frame skips these
	var desired_pos = thrall.global_position
	desired_pos.y += follow_height_offset
	velocity = (desired_pos - global_position) * (desired_pos - global_position).length_squared()
	var wanted_dist = ray_cam_pos()
	if wanted_dist < cam_current_dist and box_is_busy():
		# the line-of-sight box is still swinging the cam around the wall, so hold off on snapping in.
		# the pivot snap is the last resort now, it only kicks in once the box has given up
		pass
	elif wanted_dist < cam_current_dist:
		cam_current_dist = wanted_dist # wall's closer than the cam, snap in right away so we never see thru it
	else:
		cam_current_dist = move_toward(cam_current_dist, wanted_dist, 4.0 * delta) # all clear, ease back out at 4 m/s so it doesn't pop
	# the line-of-sight box gets a say: it swings or tilts the gantry so walls don't cover up the player,
	# and if that can't fix it the head rays jump the cam in front of the wall. gives back where the cam goes
	cam.global_position = keep_player_in_view(delta)
	draw_debug_rays()
	draw_debug_points() # little spheres on the 7 box points
	if freeze:
		return
	if velocity.length() > 10:
		velocity = velocity.normalized() * 10
	global_position += velocity * delta * 2#* (desired_pos - global_position).length()
	# wobble fix: also move along with the player's own speed so the gantry isn't always playing catch up.
	# root motion speed pulses with every step, and when the gantry only chased the player that pulse
	# turned into the lag growing and shrinking, which shows up as a wobble when you look straight down
	global_position += thrall.velocity * FOLLOW_MATCH * delta
	player_look(delta)


func ray_cam_pos():
	# Ray from the pivot back toward where the camera follow distance
	var space_state = thrall.get_world_3d().direct_space_state
	var origin = global_position
	var end = origin + (global_basis.z * cam_follow_dist)
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 1 # layer 1 is level geometry and actors i think

	# Ignore every actor so a skeleton walking behind you shouldn't push the camera in
	query.exclude = actors_to_ignore # built once at the top of this frame, see build_actor_ignore_list

	var col_result = space_state.intersect_ray(query)
	add_debug_line(origin, end, col_result) # pivot ray shows up in the debug drawing too
	if "collider" in col_result.keys():
		var _dis = global_position.distance_to(col_result["position"])
		return max(_dis - 0.2, 0.1) # sit 0.2 m in front of the wall, never behind the pivot
	return cam_follow_dist

# --- line-of-sight box ---
# moves the cam so walls don't hide the player, and gives back where the cam should go.
# order is: the sides swing the gantry (cam goes left or right), then the knees and head top tilt it
# (cam goes up) but only if the swing didn't just move it. if neither has moved the cam for a moment
# and the head's still hidden, the head rays jump the cam in front of the wall as a last resort
func keep_player_in_view(delta : float) -> Vector3:
	debug_box_points.clear()
	debug_box_pulled.clear()

	# screen right, but flattened so it stays level even when the cam is tilted up or down
	var cam_right = cam.global_basis.x
	cam_right.y = 0
	cam_right = cam_right.normalized()

	# build the box points, side is negative for screen left and positive for screen right.
	# any point that would poke into a wall gets pulled back out in front of it
	var knee_left = make_box_point(KNEE_HEIGHT, -KNEE_SIDE, cam_right)
	var knee_right = make_box_point(KNEE_HEIGHT, KNEE_SIDE, cam_right)
	var elbow_left = make_box_point(ELBOW_HEIGHT, -ELBOW_SIDE, cam_right)
	var elbow_right = make_box_point(ELBOW_HEIGHT, ELBOW_SIDE, cam_right)
	var head_top = make_box_point(HEAD_TOP_HEIGHT, 0.0, cam_right)
	var head_left = make_box_point(HEAD_SIDE_HEIGHT, -HEAD_SIDE, cam_right)
	var head_right = make_box_point(HEAD_SIDE_HEIGHT, HEAD_SIDE, cam_right)

	var left_side = [elbow_left, head_left]
	var right_side = [elbow_right, head_right]
	var low_and_top = [knee_left, knee_right, head_top]
	var all_points = [knee_left, knee_right, elbow_left, elbow_right, head_top, head_left, head_right]

	# you moved the camera yourself: the box stays out of your way (no swinging or tilting, so it doesn't
	# fight you) until you've let go of the camera and the player starts walking again
	time_since_camera_input += delta
	if box_paused and time_since_camera_input > INPUT_STOPPED_AFTER and player_is_walking():
		box_paused = false

	var box_moved = false
	if box_should_sit_out():
		cancel_box_moves() # locked on or frozen, the box stays completely out of it
	elif not box_paused:
		# the sides go first. these actually turn the gantry, same as if you'd moved the camera yourself,
		# so the cam doesn't drift back afterwards
		swing_to_see_sides(left_side, right_side, all_points, delta)
		box_moved = swinging

		# the tilt waits while the sides are swinging, otherwise running behind a wall
		# hides the knees and a side at once and the cam goes up AND out
		if not swinging:
			box_moved = tilt_up_to_see(low_and_top, delta)

	if box_moved:
		time_since_box_moved = 0.0
	else:
		time_since_box_moved += delta

	var cam_spot = get_cam_spot()

	# last resort: once the box hasn't moved the cam for LAST_RESORT_WAIT seconds and the head's
	# still hidden, it's had its chance, so the head rays jump the cam right up to the wall
	if box_is_busy():
		return cam_spot
	var head_points = [head_top, head_left, head_right]
	return jump_to_closest_head_hit(head_points, cam_spot)


# true while the swing or tilt is still working on it (or only just stopped).
# the head jump and the pivot snap both wait until this goes false
func box_is_busy() -> bool:
	return time_since_box_moved < LAST_RESORT_WAIT


# called from player_look and _input whenever you move the camera with the stick or mouse.
# the box backs off: any swing or tilt gets cancelled, and it stays off until the player walks again.
# it also stops counting as busy, so the pivot snap and head jump keep the cam out of walls right away
func pause_box_for_camera_input() -> void:
	time_since_camera_input = 0.0
	box_paused = true
	cancel_box_moves()


# stops any swing or tilt that's going, and stops the box counting as busy so the pivot snap
# and head jump can keep the cam out of walls right away. used by the input pause, lock-on and freeze
func cancel_box_moves() -> void:
	end_swing()
	swinging = false
	tilt_extra_left = 0.0
	time_since_box_moved = 999.0 # not busy, so the last resorts are allowed straight away


# the box sits out completely while locked on (player_look aims the gantry at the target every frame,
# which would just undo any swing) or while frozen (a scripted shot like the level exit is running)
func box_should_sit_out() -> bool:
	if freeze:
		return true
	if cam.target_curr != Vector3.ZERO:
		return true # locked on, same check player_look uses
	return false


# every actor's physics body, so the camera rays only ever see level geometry. built once per frame
# (not once per ray) because Actor.ALL_EVER_MADE keeps every actor ever spawned and never shrinks
func build_actor_ignore_list() -> Array[RID]:
	var ignore_list : Array[RID] = []
	for actor in Actor.ALL_EVER_MADE:
		if is_instance_valid(actor):
			ignore_list.append(actor.get_rid())
	return ignore_list


# is the player actually moving across the ground (not just an idle animation shuffling them a bit)?
func player_is_walking() -> bool:
	var flat_speed = Vector3(thrall.velocity.x, 0, thrall.velocity.z).length()
	return flat_speed > WALK_TO_RESUME_SPEED


# builds one box point: from the player's feet go up to the point's height and out to the side.
# then checks a line from the player's middle (chest height) out to that point. if it hits a wall,
# the point would be poking into it, so it gets pulled back to just in front of the wall.
# a point inside a wall gives junk ray answers, sometimes "clear" and sometimes "blocked" by the wall block next door
func make_box_point(height : float, side : float, cam_right : Vector3) -> Vector3:
	var feet = thrall.global_position
	var middle = feet + (Vector3.UP * follow_height_offset)
	var wanted = feet + (Vector3.UP * height) + (cam_right * side)

	var point = wanted
	var pulled = false
	var hit = cast_wall_ray(middle, wanted, false)
	if not hit.is_empty():
		var toward_middle = (middle - wanted).normalized()
		point = hit["position"] + (toward_middle * POINT_WALL_GAP)
		pulled = true

	debug_box_points.append(point)
	debug_box_pulled.append(pulled)
	return point


# where the cam goes on the end of the arm, using the gantry's current direction and the arm's current length
func get_cam_spot() -> Vector3:
	return global_position + (global_basis.z * cam_current_dist)


# where the cam would end up if the gantry tilted by this many degrees (negative = cam goes up)
func cam_spot_after_tilt(degrees : float) -> Vector3:
	var arm = global_basis.z.rotated(global_basis.x.normalized(), deg_to_rad(degrees))
	return global_position + (arm * cam_current_dist)


# where the cam would end up if the gantry swung around by this many degrees (positive = cam goes screen right)
func cam_spot_after_swing(degrees : float) -> Vector3:
	var arm = global_basis.z.rotated(Vector3.UP, deg_to_rad(degrees))
	return global_position + (arm * cam_current_dist)


# sides: if the left side of the box (left elbow or left of the head) is hidden, swing the cam screen right,
# if the right side is hidden swing it screen left. if both sides are hidden (the whole player's behind the
# wall) keep swinging the way we already were, which follows the player around the corner they just ran past.
# if there's no swing going yet, look ahead both ways and go toward the side that sees more of the box.
# the swing speeds up the longer the box stays hidden, and keeps going PUSH_EXTRA meters once it's all visible
func swing_to_see_sides(left_side : Array, right_side : Array, all_points : Array, delta : float) -> void:
	swinging = false # assume no swing this frame until we actually turn the cam
	var cam_spot = get_cam_spot()

	var left_hidden = any_blocked(left_side, cam_spot)
	var right_hidden = any_blocked(right_side, cam_spot)

	if left_hidden or right_hidden:
		var direction = 0.0
		if left_hidden and not right_hidden:
			direction = 1.0 # left side hidden = swing the cam screen right
		elif right_hidden and not left_hidden:
			direction = -1.0 # right side hidden = swing it screen left
		elif swing_direction != 0.0:
			direction = swing_direction # whole player hidden mid-swing, keep going the same way around the corner
		else:
			direction = pick_swing_direction(all_points) # whole player hidden and no swing yet, look ahead

		if direction == 0.0:
			end_swing() # neither way looks any better, let the tilt or the last resorts handle it
			return

		if direction != swing_direction:
			# brand new swing (or it changed direction), so start counting and speeding up from scratch
			swing_turned_so_far = 0.0
			swing_speed = SWING_START_SPEED
		swing_direction = direction
		swing_extra_left = PUSH_EXTRA # keep topped up while hidden, so the extra starts once it's all visible
		swing_speed = min(swing_speed + (SWING_SPEED_UP * delta), SWING_TOP_SPEED) # hidden for longer = swing faster
	elif swing_extra_left <= 0.0:
		end_swing() # everything's visible and the extra swing is done
		return

	if swing_turned_so_far >= SWING_MAX_TURN:
		swing_extra_left = 0.0 # swung as far as one swing is allowed, let the last resorts handle it
		return

	var step_degrees = swing_speed * delta * swing_direction
	var next_spot = cam_spot_after_swing(step_degrees)
	if not has_room_for_cam(cam_spot, next_spot):
		swing_extra_left = 0.0 # wall right next to the cam, swinging more would shove the cam into it
		return

	rotate_y(deg_to_rad(step_degrees))
	camTimer = 12.0 # counts as moving the camera, so the 12 s recenter in player_look leaves it alone
	swing_turned_so_far += abs(step_degrees)
	swinging = true

	if not (left_hidden or right_hidden):
		swing_extra_left -= cam_spot.distance_to(next_spot) # count down the extra by how far the cam just moved


# a swing is over, reset everything so the next one starts fresh
func end_swing() -> void:
	swing_direction = 0.0
	swing_speed = SWING_START_SPEED
	swing_turned_so_far = 0.0
	swing_extra_left = 0.0


# looks ahead: how many box points could see the cam if the gantry swung SWING_LOOK_AHEAD degrees right,
# and how many if it swung left? gives back +1 (right) or -1 (left) for whichever sees more, 0 if it's a tie
func pick_swing_direction(all_points : Array) -> float:
	var seen_if_right = count_visible_from(all_points, cam_spot_after_swing(SWING_LOOK_AHEAD))
	var seen_if_left = count_visible_from(all_points, cam_spot_after_swing(-SWING_LOOK_AHEAD))
	if seen_if_right > seen_if_left:
		return 1.0
	if seen_if_left > seen_if_right:
		return -1.0
	return 0.0


# knees and head top: if any of them are hidden, tilt the gantry so the cam goes up.
# keeps going PUSH_EXTRA meters after they show up again. gives back true if it actually moved the cam
func tilt_up_to_see(points : Array, delta : float) -> bool:
	var cam_spot = get_cam_spot()
	var hidden = any_blocked(points, cam_spot)

	if hidden:
		tilt_extra_left = PUSH_EXTRA # keep this topped up while hidden, so the extra starts once they're visible
	elif tilt_extra_left <= 0.0:
		return false # all visible and the extra tilt is done, nothing to do

	if global_rotation_degrees.x <= -60.0:
		tilt_extra_left = 0.0 # already tilted as far as the camera's allowed to go (same limit as player_look)
		return false

	var step_degrees = TILT_SPEED * delta
	var next_spot = cam_spot_after_tilt(-step_degrees) # negative tilt = cam goes up
	if not has_room_for_cam(cam_spot, next_spot):
		tilt_extra_left = 0.0 # ceiling or something right there, tilting more would shove the cam into it
		return false

	rotate(global_basis.x.normalized(), deg_to_rad(-step_degrees))
	global_rotation_degrees.x = clamp(global_rotation_degrees.x, -60, 20) # same limits as player_look
	global_rotation_degrees.z = 0
	camTimer = 12.0 # counts as moving the camera, so the 12 s recenter in player_look leaves it alone

	if not hidden:
		tilt_extra_left -= cam_spot.distance_to(next_spot) # count down the extra by how far the cam just moved
	return true


# true if any of these points can't see the spot. checks every point (even after finding one)
# so all the rays show up in the debug drawing
func any_blocked(points : Array, spot : Vector3) -> bool:
	var found_one = false
	for point in points:
		if is_blocked(point, spot, true):
			found_one = true
	return found_one


# how many of these points can see the spot (not drawn in debug, it's just a look ahead)
func count_visible_from(points : Array, spot : Vector3) -> int:
	var count = 0
	for point in points:
		if not is_blocked(point, spot, false):
			count += 1
	return count


# head: if any head ray is blocked, the cam jumps right up to where it hit, backed off the wall a bit.
# if more than one is blocked, use the hit closest to the player since that's the wall actually in the way
func jump_to_closest_head_hit(head_points : Array, cam_pos : Vector3) -> Vector3:
	var new_cam_pos = cam_pos # if nothing's in the way the cam stays put
	var closest_hit_dist = -1.0 # -1 means we haven't found a hit yet

	for head_point in head_points:
		var hit = cast_wall_ray(head_point, cam_pos, true)
		if hit.is_empty():
			continue # this one can see the cam fine

		var hit_pos = hit["position"]
		var hit_dist = head_point.distance_to(hit_pos)
		if closest_hit_dist < 0 or hit_dist < closest_hit_dist:
			closest_hit_dist = hit_dist
			# back off the wall toward the head, but never further than the head itself
			var back_off = min(WALL_MARGIN, hit_dist)
			var toward_head = (head_point - hit_pos).normalized()
			new_cam_pos = hit_pos + (toward_head * back_off)

	return new_cam_pos


# fires one ray from -> to and only cares about level geometry (every actor gets ignored,
# same as the pivot ray). gives back godot's hit dictionary, which is empty if nothing's in the way
func cast_wall_ray(from : Vector3, to : Vector3, show_in_debug : bool) -> Dictionary:
	var space_state = thrall.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1

	query.exclude = actors_to_ignore # built once at the top of this frame, see build_actor_ignore_list

	var hit = space_state.intersect_ray(query)
	if show_in_debug:
		add_debug_line(from, to, hit)
	return hit


# same as cast_wall_ray but just a yes or no, is something in the way
func is_blocked(from : Vector3, to : Vector3, show_in_debug : bool) -> bool:
	var hit = cast_wall_ray(from, to, show_in_debug)
	return not hit.is_empty()


# can the cam move from from_spot over to next_spot without going into a wall?
# checks a little past next_spot too (WALL_MARGIN) so the cam doesn't end up kissing the wall.
# without this a knee push could tilt the cam right up through a ceiling
func has_room_for_cam(from_spot : Vector3, next_spot : Vector3) -> bool:
	var push_direction = (next_spot - from_spot).normalized()
	var check_until = next_spot + (push_direction * WALL_MARGIN)
	return not is_blocked(from_spot, check_until, false)


# --- debug drawing ---
# remembers a ray so draw_debug_rays can draw it. blocked rays only get drawn up to where they hit
func add_debug_line(from : Vector3, to : Vector3, hit : Dictionary) -> void:
	if not show_debug_rays:
		return
	if hit.is_empty():
		debug_lines.append({"from": from, "to": to, "blocked": false})
	else:
		debug_lines.append({"from": from, "to": hit["position"], "blocked": true})


# draws every ray from this frame as a line, green = clear, red = blocked.
# heads up: a ray that ends right at the cam points straight at you, so from the game cam it's basically invisible.
# you only see lines when the cam isn't where the rays end (like after a head jump)
func draw_debug_rays() -> void:
	if not show_debug_rays:
		if debug_mesh_instance != null:
			debug_mesh_instance.visible = false # got turned off mid-game, hide what's already there
		return

	if debug_mesh_instance == null:
		make_debug_mesh() # first time it's turned on, build the thing we draw into
	debug_mesh_instance.visible = true

	debug_mesh.clear_surfaces() # wipe last frame's lines
	if debug_lines.size() == 0:
		return # nothing to draw, and godot complains about an empty surface

	debug_mesh.surface_begin(Mesh.PRIMITIVE_LINES) # every 2 points we add = one line
	for line in debug_lines:
		var color = Color.GREEN
		if line["blocked"]:
			color = Color.RED
		debug_mesh.surface_set_color(color)
		debug_mesh.surface_add_vertex(line["from"])
		debug_mesh.surface_set_color(color)
		debug_mesh.surface_add_vertex(line["to"])
	debug_mesh.surface_end()


# builds the mesh the debug lines get drawn into. it's a child of the gantry so it gets cleaned up
# with the level, and top_level so it draws in world space instead of riding along with the gantry
func make_debug_mesh() -> void:
	debug_mesh = ImmediateMesh.new()

	var line_material = StandardMaterial3D.new()
	line_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED # flat color, lighting doesn't matter
	line_material.vertex_color_use_as_albedo = true # use the green/red we set on each point
	line_material.no_depth_test = true # draw on top of walls so you can see rays going behind stuff
	line_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA # draws after all the solid stuff, so walls can't cover the lines up

	debug_mesh_instance = MeshInstance3D.new()
	debug_mesh_instance.mesh = debug_mesh
	debug_mesh_instance.material_override = line_material
	debug_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	debug_mesh_instance.top_level = true
	add_child(debug_mesh_instance)


# puts a little sphere on each of the 7 box points, every frame while debug is on.
# green = the cam can see it right now, red = a wall is hiding it from the cam right now,
# yellow = it would've been poking into a wall so it got pulled back out in front of it
func draw_debug_points() -> void:
	if not show_debug_rays:
		for marker in debug_point_markers:
			marker.visible = false # got turned off mid-game, hide what's already there
		return

	if debug_point_markers.size() == 0:
		make_debug_point_markers() # first time it's turned on, make the spheres

	for i in debug_box_points.size():
		var point = debug_box_points[i]
		var marker = debug_point_markers[i]
		marker.visible = true
		marker.global_position = point
		if is_blocked(point, cam.global_position, false):
			marker.material_override = debug_hidden_material
		elif debug_box_pulled[i]:
			marker.material_override = debug_pulled_material
		else:
			marker.material_override = debug_clear_material


# makes one small sphere for each box point, plus the green, red and yellow materials they swap between.
# children of the gantry and top_level, same deal as the debug lines
func make_debug_point_markers() -> void:
	debug_clear_material = make_debug_point_material(Color.GREEN)
	debug_hidden_material = make_debug_point_material(Color.RED)
	debug_pulled_material = make_debug_point_material(Color.YELLOW)

	var sphere = SphereMesh.new()
	sphere.radius = 0.05 # 10 cm across, big enough to spot, small enough to not hide the player
	sphere.height = 0.1

	for i in debug_box_points.size():
		var marker = MeshInstance3D.new()
		marker.mesh = sphere
		marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		marker.top_level = true
		add_child(marker)
		debug_point_markers.append(marker)


# flat color material that draws on top of everything, so a marker inside the player's body
# or behind a wall still shows up
func make_debug_point_material(color : Color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.no_depth_test = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA # draws after all the solid stuff, so walls can't cover it up
	return material


func player_look(delta):
	var disLook =  Input.get_vector("p1_look_left", "p1_look_right", "p1_look_dn", "p1_look_up")
	look_rotation_vel = disLook * delta * camLookAccell
	var default_angle = -20
	if cam.target_curr == Vector3.ZERO: # NOTE - No target
		rotate(global_basis.x.normalized(), look_rotation_vel.y)
		rotate_y(-look_rotation_vel.x)
		global_rotation_degrees.x = clamp(global_rotation_degrees.x, -60,20)
	else:
		var original_rot_x = global_rotation_degrees.x
		look_at(cam.target_curr)
		global_rotation_degrees.x = original_rot_x
		#global_rotation_degrees.y = global_rotation_degrees.y #rotate_toward(original_rot_y, global_rotation_degrees.y, 50 * delta)
		default_angle = -35
	global_rotation_degrees.z = 0
	#recentering here, add some timer so the rebound isn't immediate 
	if disLook.length() != 0: #some kind of input 
		camTimer = 12.0
		pause_box_for_camera_input() # you're moving the camera with the stick, the box backs off (see keep_player_in_view)
	else:
		#subtraction should be proportional to framerate
		#higher refresh rate would decrement the same as lower
		camTimer -= delta
	if camTimer <= 0:
		global_rotation_degrees.x += (default_angle-global_rotation_degrees.x) * 0.9 * delta
	


func _input(event):
	if event is InputEventMouseMotion:
		#mouse movement will always reset timer
		camTimer = 12.0
		pause_box_for_camera_input() # you're moving the camera with the mouse, the box backs off (see keep_player_in_view)
		var disLook =  event.relative * 0.01
		look_rotation_vel = disLook * 0.1 * camLookAccell
		var default_angle = -20
		if cam.target_curr == Vector3.ZERO: # NOTE - No target
			rotate(global_basis.x.normalized(), -look_rotation_vel.y) # negative y because screen coords pos y is down
			rotate_y(-look_rotation_vel.x)
			global_rotation_degrees.x = clamp(global_rotation_degrees.x, -60,20)
		else:
			var original_rot_x = global_rotation_degrees.x
			look_at(cam.target_curr)
			global_rotation_degrees.x = original_rot_x
			#global_rotation_degrees.y = global_rotation_degrees.y #rotate_toward(original_rot_y, global_rotation_degrees.y, 50 * delta)
			default_angle = -35
		global_rotation_degrees.z = 0
		#global_rotation_degrees.x += (default_angle-global_rotation_degrees.x) * 0.9 * 0.1
	#KEY_ESCAPE cant persist because user moves mouse in pause menu
	#need a global to block MOUSE_MODE_CAPTURED
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#for some reason this is true regardless: