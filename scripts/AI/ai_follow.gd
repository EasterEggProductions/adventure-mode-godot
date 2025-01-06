extends Node
# NOTE - thralling methods do not check of establis que at this time

@onready var thrall = get_parent()

@export var followGuy : Node3D # Point in space from which to flee
@export var leashDist = 5.0

var goTo : Vector3

var dot : MeshInstance3D # debug

@export var follow = true
# Called when the node enters the scene tree for the first time.
func _ready():
	goTo = thrall.global_position
	makeDot()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if follow:
		var go_dir = Vector3.ZERO#(followGuy.global_position - thrall.global_position).normalized() * 0.1
		if thrall.global_position.distance_to(followGuy.global_position) > leashDist:
			goTo = find_somewhere_to_go()
			go_dir = goTo - thrall.global_position
		thrall.handle_movement(go_dir)
		dot.global_position = goTo

func find_somewhere_to_go() -> Vector3:
	return thrall.global_position - ((thrall.global_position - followGuy.global_position) / 2)


func makeDot():
		#debug
	var sphere = SphereMesh.new()
	sphere.radial_segments = 7
	sphere.radius = 0.125
	sphere.height = 0.25
	dot = MeshInstance3D.new()
	dot.mesh = sphere
	get_tree().root.add_child.call_deferred(dot)
	dot.name = "~dot~"