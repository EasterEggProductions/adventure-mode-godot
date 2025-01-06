extends Control

@export var seize_focus = false

@onready var status_readout = $status_readout
@onready var dpad_itemMenu = $dpad_itemMenu
@onready var currency_readout = $currency_readout
@onready var action_prompt = $Action_prompt
@onready var menu_start = $menu_start

var player_socket
var thrall

# TODO - on thrall change signal? Idk

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_released("p1_start"):
		menu_start.visible = !menu_start.visible
		dpad_itemMenu.visible = !menu_start.visible
		status_readout.visible = !menu_start.visible
		if menu_start.visible:
			menu_start.find_child("buttons").get_child(0).grab_focus()


func _quit():
	get_tree().quit()

func inspect_new_thrall(new_thrall : Actor):
	thrall = new_thrall
	status_readout.inspect_new_thrall(new_thrall)