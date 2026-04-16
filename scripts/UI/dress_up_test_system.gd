extends Node

@export var outfit_control : Control 

func _ready() -> void:
    var dresser_upper : DresserUpper = MgrPlayerSocket.get_player_one().thrall.find_child("DresserUpper")
    if dresser_upper:
        outfit_control.dress_up_controller = dresser_upper
        outfit_control.make_garment_buttons.call_deferred()