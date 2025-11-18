extends Control

@export var seize_focus = false

@onready var status_readout = $status_readout
@onready var dpad_itemMenu = $dpad_itemMenu
@onready var currency_readout = $currency_readout
@onready var action_prompt = $Action_prompt
@onready var menu_start = $menu_start

var player_socket
var thrall : Actor
var fade_timer = 0.0
var fade_tweener : Tween

# TODO - on thrall change signal? Idk

# Called when the node enters the scene tree for the first time.
func _ready():
	if thrall == null:
		modulate = Color.TRANSPARENT
	fade_tweener = get_tree().create_tween()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("p1_start"):
		menu_start.visible = !menu_start.visible
		dpad_itemMenu.visible = !menu_start.visible
		status_readout.visible = !menu_start.visible
		if menu_start.visible:
			menu_start.find_child("buttons").get_child(0).grab_focus()
	if Input.is_anything_pressed():
		fade_timer = 10.0
		if is_instance_valid(fade_tweener):
			fade_tweener.stop()
		if modulate != Color.WHITE:
			fade_tweener = get_tree().create_tween()
			fade_tweener.tween_property(self, "modulate", Color.WHITE, 0.25)
		#modulate = Color.WHITE

	if fade_timer <= 0 and is_instance_valid(fade_tweener):
		fade_tweener.stop()
		fade_tweener = get_tree().create_tween()
		fade_tweener.tween_property(self, "modulate", Color.TRANSPARENT, 0.1)
	else: 
		fade_timer -= delta




func _quit():
	get_tree().quit()

func inspect_new_thrall(new_thrall : Actor):
	thrall = new_thrall
	status_readout.inspect_new_thrall(new_thrall)
	#dpad_itemMenu.inspect_new_thrall(new_thrall)
