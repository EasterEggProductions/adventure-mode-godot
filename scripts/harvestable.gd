extends Area3D
class_name Harvestable
@export var death_effect : PackedScene
@export var harvest_name = "Fruit"
@export var item : InventoryItem
signal picked_up
var collected = false

		
func my_pickup_logic():
	if collected != false:
		return
	collected = true

	$audio.play()
	emit_signal("picked_up")
	monitoring = false

	if is_connected("body_entered", my_pickup_logic):
		disconnect("body_entered", my_pickup_logic)

	var player = MgrPlayerSocket.get_player_one().thrall
	var target_pos = player.global_position + Vector3(0, 1.2, 0) # approximately chest height 

	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "global_position", target_pos, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "scale", Vector3.ONE * 0.001, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "rotation", rotation + Vector3(0, 10*TAU, 0), 5)

	tween.tween_callback(self.queue_free)

	MgrPlayerSocket.get_player_one().thrall.character.my_inventory.append(item)
