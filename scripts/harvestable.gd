extends Area3D
class_name Harvestable
@export var collect_test = false
@export var death_effect : PackedScene
@export var harvest_name = "Fruit"
signal picked_up
var collected = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#connect("body_entered", my_pickup_logic)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if collect_test:
		collect_test = false
		#my_pickup_logic()
		

func my_pickup_logic():
	if collected != false:
		return
	collected = true
	$audio.play()
	emit_signal("picked_up")
	monitoring = false # to make sure we only get one pickup
	disconnect("body_entered", my_pickup_logic)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector3.ONE * 1.3, 0.1)
	tween.tween_property(self, "scale", Vector3.ZERO, 0.1)
	tween.tween_property(self, "global_position", Vector3.ZERO, 5)
	tween.tween_callback(self.queue_free)