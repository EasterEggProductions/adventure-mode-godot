extends Control

var thrall : Actor
@onready var tx_belt : TextureRect = $item_belt
@onready var tx_spell : TextureRect = $item_spell
@onready var tx_left : TextureRect = $item_left
@onready var tx_right : TextureRect = $item_right

@onready var aud : AudioStreamPlayer = $aud

## Archetecture is a bit wonky here. 
## We are going to have the player socket address this
## This will then... 
## Nah, fuck it, we will just poll shit every frame! lol

var last_left = 0
var last_right = 0
var last_spell = 0
var last_belt = 0

func _process(delta: float) -> void:
	if is_instance_valid(thrall):
		if thrall.character.belt_current != last_belt:
			update_belt()
		if thrall.character.hand_r_current != last_right:
			update_right()
		if thrall.character.hand_l_current != last_left:
			update_left()
		if thrall.character.spell_current != last_spell:
			update_spell()


func inspect_new_thrall(new_thrall : Actor):
	thrall = new_thrall
	last_belt = thrall.character.belt_current
	last_right = thrall.character.hand_r_current
	last_left = thrall.character.hand_l_current
	last_spell = thrall.character.spell_current
	update_belt()
	update_right()
	update_left()
	update_spell()
	var tween = get_tree().create_tween()
	aud.volume_linear = 0
	tween.tween_property(aud, "volume_linear", 1, 3) # Workaround to silence on new inspection.


func update_belt():
	last_belt = thrall.character.belt_current
	update_slot(last_belt, thrall.character.belt_items, tx_belt)

func update_right():
	last_right = thrall.character.hand_r_current
	update_slot(last_right, thrall.character.hand_right_slots, tx_right)

func update_left():
	last_left = thrall.character.hand_l_current	
	update_slot(last_left, thrall.character.hand_left_slots, tx_left)

func update_spell():
	last_spell = thrall.character.spell_current
	update_slot(last_spell, thrall.character.spells_slots, tx_spell)

func update_slot(current : int, slots : Array[InventoryItem], tx : TextureRect):
	if len(slots) == 0 or current < 0:
		tx.texture = null
		tx.visible = false
		aud.play()
		return
	tx.texture = slots[current].icon
	tx.visible = true
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tx.scale = Vector2.ONE * 1.25
	tween.tween_property(tx, "scale", Vector2.ONE, 0.1)
	aud.play()
	#tween.tween_callback(tx.queue_free)
