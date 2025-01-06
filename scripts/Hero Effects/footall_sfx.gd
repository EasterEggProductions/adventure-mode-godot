extends Node

var sense_left : Area3D
var sense_right : Area3D

var left_up = false
var right_up = false

var left_boneFollow : BoneAttachment3D
var right_boneFollow : BoneAttachment3D

var left_aud : AudioStreamPlayer3D
var right_aud : AudioStreamPlayer3D

var sounds = [
	preload("res://art/audio/footstep_sounds/step_gravel_01.ogg"),
	preload("res://art/audio/footstep_sounds/step_gravel_02.ogg"),
	preload("res://art/audio/footstep_sounds/step_gravel_03.ogg"),
	preload("res://art/audio/footstep_sounds/step_gravel_04.ogg"),
	preload("res://art/audio/footstep_sounds/step_gravel_05.ogg"),
	preload("res://art/audio/footstep_sounds/step_gravel_06.ogg")
]

var randSoundQue = []

var footfall_partifle

# Called when the node enters the scene tree for the first time.
func _ready():
	left_aud = AudioStreamPlayer3D.new()
	right_aud = AudioStreamPlayer3D.new()
	left_aud.volume_db = -13
	left_aud.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
	right_aud.volume_db = -13
	right_aud.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
	get_tree().root.add_child.call_deferred(left_aud)
	get_tree().root.add_child.call_deferred(right_aud)
	for kid in get_parent().get_node("skeleton/char/Skeleton3D").get_children():
		pass
		#print(kid)
	setup_footfall(get_parent().get_node("skeleton/char/Skeleton3D"))

	randSoundQue.append_array(sounds)
	footfall_partifle = preload("res://prefabs/Hero Effects/footfall_particle.tscn").instantiate()
	get_tree().root.add_child.call_deferred(footfall_partifle)



func setup_footfall(skele : Skeleton3D):
	left_boneFollow = BoneAttachment3D.new()
	left_boneFollow.name = "left_boneFollow"
	sense_left = Area3D.new()
	sense_left.name = "sense_left"
	var col_L = CollisionShape3D.new()
	col_L.shape = SphereShape3D.new()
	col_L.shape.radius = 0.1
	sense_left.add_child(col_L)
	left_boneFollow.add_child(sense_left)
	left_boneFollow.bone_name = "toe.L"
	sense_left.connect("body_entered", footfall_left)
	sense_left.connect("body_exited", footup_left)


	right_boneFollow = BoneAttachment3D.new()
	right_boneFollow.name = "right_boneFollow"
	sense_right = Area3D.new()
	sense_right.name = "sense_right"
	var col_R = CollisionShape3D.new()
	col_R.shape = SphereShape3D.new()
	col_R.shape.radius = 0.1
	sense_right.add_child(col_R)
	right_boneFollow.add_child(sense_right)
	right_boneFollow.bone_name = "toe.R"
	sense_right.connect("body_entered", footfall_right)
	sense_right.connect("body_exited", footup_right)

	skele.add_child(right_boneFollow)
	skele.add_child(left_boneFollow)




func footfall_left(_item):
	#print("left dn")
	#makeDebugDot(sense_left.global_position)
	left_aud.global_position = sense_left.global_position
	# Pop front sound, randomly put in last or second to last spot
	footSound(left_aud)
	footfallParticle(sense_left.global_position)

func footup_left(_item):	
	pass
	#print("left up")
	#makeDebugDot(sense_left.global_position)

func footfall_right(_item):	
	#print("right dn")
	#makeDebugDot(sense_right.global_position)
	right_aud.global_position = sense_right.global_position
	footSound(right_aud)
	footfallParticle(sense_right.global_position)

func footup_right(_item):
	pass
	#print("right up")
	#makeDebugDot(sense_right.global_position)

func footSound(aud : AudioStreamPlayer3D):
	# Pop front sound, randomly put in last or second to last spot
	var n_sound =  randSoundQue.pop_front()
	aud.stream = n_sound
	aud.pitch_scale = randf() * 0.5 + 0.75
	aud.play()
	if randf() > 0.5:
		randSoundQue.insert(randSoundQue.size() - 2, n_sound)
	else:
		randSoundQue.append(n_sound)

func footfallParticle(pos : Vector3):
	footfall_partifle.global_position = pos
	footfall_partifle.emit_particle(footfall_partifle.transform, Vector3.UP, Color.WHITE, Color.WHITE, 0)
	footfall_partifle.emit_particle(footfall_partifle.transform, Vector3.UP, Color.WHITE, Color.WHITE, 0)
	footfall_partifle.emit_particle(footfall_partifle.transform, Vector3.UP, Color.WHITE, Color.WHITE, 0)
	footfall_partifle.emit_particle(footfall_partifle.transform, Vector3.UP, Color.WHITE, Color.WHITE, 0)

func makeDebugDot(pos : Vector3):
		#debug
	var sphere = SphereMesh.new()
	sphere.radial_segments = 7
	sphere.radius = 0.125
	sphere.height = 0.25
	var dot = MeshInstance3D.new()
	dot.mesh = sphere
	get_tree().root.add_child(dot)
	dot.name = "~dot~"
	dot.global_position = pos
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(dot, "scale", Vector3.ZERO, 5)
	tween.tween_callback(dot.queue_free)