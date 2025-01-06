extends AnimatableBody3D

@export var ease_type = Tween.EASE_IN_OUT
@export var transition = Tween.TRANS_LINEAR
@onready var tween : Tween = get_tree().create_tween()
@export var other_position = Vector3.ZERO # probably a better way to do this
@onready var start_position : Vector3 = global_position
@export var move_time = 10
var at_start = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tween.stop()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func begin_move(_nothing_body):
	print("we did it")
	if tween.is_running():
		print("tween was running")
		return
	tween.set_ease(ease_type)
	tween.set_trans(transition)
	if at_start:
		print("move to pos 2")
		tween.tween_property(self, "global_position", other_position, move_time)
		tween.play()
		at_start = false
	else:
		print("move to start pos")
		tween.tween_property(self, "global_position", start_position, move_time)
		tween.play()
		at_start = true