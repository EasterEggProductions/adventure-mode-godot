extends Node
# NOTE - thralling methods do not check of establis que at this time

@onready var thrall = get_parent()

@export var fleeFrom : Node3D # Point in space from which to flee
@export var fleeDist = 5.0

var goTo : Vector3
var fleeing = false

var dot : MeshInstance3D # debug


# Called when the node enters the scene tree for the first time.
func _ready():
	goTo = thrall.global_position
	makeDot()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fleeing == false && thrall.global_position.distance_to(fleeFrom.global_position) < fleeDist:
		goTo = find_somewhere_to_go()
		fleeing = true
		print("Flee!")
	elif fleeing:
		var go_dir = goTo - thrall.global_position
		#print(go_dir.length())
		thrall.handle_movement(go_dir)
		if thrall.global_position.distance_to(goTo) < 0.2: # NOTE Arrival threshold is magic number
			print("Successfully fled!")
			fleeing = false
	else:
		var go_dir = (fleeFrom.global_position - thrall.global_position).normalized() * 0.1
		thrall.handle_movement(go_dir)

	dot.global_position = goTo

func find_somewhere_to_go() -> Vector3:
	return thrall.global_position + ((thrall.global_position - fleeFrom.global_position).normalized() * fleeDist * 2)


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