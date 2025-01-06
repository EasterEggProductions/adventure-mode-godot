extends Node3D

@onready var skele : Skeleton3D = $trail/Skeleton3D

var max_cache_size = 6 * 2
var bone_chain_length = 6

var test_pos = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	test_pos.push_front(global_transform)
	if test_pos.size() > max_cache_size:
		test_pos.pop_back()
	trail()

func trail():
	var chunky = test_pos.size() / float(bone_chain_length)
	for x in range(6):
		var mTrans = test_pos[x*chunky]
		mTrans = global_transform.affine_inverse() * mTrans
		skele.set_bone_global_pose_override(x,mTrans, 1)

func stop():
	visible = false 

func restart():
	test_pos.clear()
	for x in range(bone_chain_length):
		test_pos.push_front(global_transform)
	visible = true