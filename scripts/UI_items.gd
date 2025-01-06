extends Control

@export var thrall : Actor
@export var ico_fruit : TextureRect 
@export var txt_fruit : Label
@export var ico_coins : TextureRect 
@export var txt_coins : Label

@export var door_unlock : Node3D

var cnt_fruit = 0
var cnt_coins = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#thrall.item_get.connect(_item_watch)
	# TODO sign up to signals
	pass # Replace with function body.



func update_readout(ico : TextureRect, txt : Label, cnt : int):
	var tween_ico = get_tree().create_tween()
	var tween_txt = get_tree().create_tween()
	tween_ico.set_ease(Tween.EASE_OUT)
	tween_ico.set_trans(Tween.TRANS_ELASTIC)
	tween_txt.set_ease(Tween.EASE_IN)
	tween_txt.set_trans(Tween.TRANS_ELASTIC)
	tween_ico.tween_property(ico, "position", Vector2.ZERO, 1)
	txt.scale = Vector2(4,4)
	txt.text = str(cnt)
	tween_txt.tween_property(txt, "scale", Vector2(3,3), 0.5) 

func _item_watch(itmeName : String):
	if itmeName == "coin":
		_get_coins()
	else:
		_get_fruit()
	if cnt_fruit > 0 and cnt_coins > 0:
		door_unlock.locked = false

func _get_fruit():
	cnt_fruit += 1
	update_readout(ico_fruit, txt_fruit, cnt_fruit)

func _get_coins():
	cnt_coins += 1
	update_readout(ico_coins, txt_coins, cnt_coins)