extends Area3D

var collected = false


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", __body_enter)
	$coin/AnimationPlayer.play("coin_spin")
	pass # Replace with function body.



func __body_enter(dat):
	if collected == false:
		print("Collect coin!")
		$aud.play()
		collected = true
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(self, "scale", Vector3.ZERO, 0.1)
		tween.tween_property(self, "scale", Vector3.ZERO, 2)
		tween.tween_callback(self.queue_free)
		var thrall = dat as Actor
		thrall.item_get.emit("coin")


