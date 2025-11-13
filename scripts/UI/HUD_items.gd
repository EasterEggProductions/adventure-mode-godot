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

func update_belt():
    last_belt = thrall.character.belt_current
    #tx_right.texture = thrall.character.hand_right_slots[last_right]
    tx_tween(tx_belt)
    aud.play()

func update_right():
    last_right = thrall.character.hand_r_current
    #tx_right.texture = thrall.character.hand_right_slots[last_right]
    tx_tween(tx_right)
    aud.play()

func update_left():
    last_left = thrall.character.hand_l_current
    #tx_right.texture = thrall.character.hand_right_slots[last_right]
    tx_tween(tx_left)
    aud.play()

func update_spell():
    last_spell = thrall.character.spell_current
    #tx_right.texture = thrall.character.hand_right_slots[last_right]
    tx_tween(tx_spell)
    aud.play()


func tx_tween(tx : TextureRect):
    var tween = get_tree().create_tween()
    tween.set_ease(Tween.EASE_IN)
    tween.set_trans(Tween.TRANS_BACK)
    tx.scale = Vector2.ONE * 2
    tween.tween_property(tx, "scale", Vector2.ONE, 0.1)
    #tween.tween_callback(tx.queue_free)