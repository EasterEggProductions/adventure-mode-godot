extends Menu

@export var seize_focus = false

@onready var status_readout = $status_readout
@onready var dpad_itemMenu = $dpad_itemMenu
@onready var currency_readout = $currency_readout
@onready var action_prompt = $Action_prompt
@export var menu_start : PackedScene

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
	MgrPlayerSocket.get_player_one().headsUpDisplay = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if child_menu == null and Input.is_action_just_released("p1_start"):
		open_submenu(menu_start)
		player_socket = MgrPlayerSocket.get_player_one()
		player_socket.cont_state = player_socket.ControlState.WALK_ONLY
	if Input.is_anything_pressed() and is_instance_valid(thrall):
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
	dpad_itemMenu.inspect_new_thrall(new_thrall)

func focus():
	player_socket = MgrPlayerSocket.get_player_one()
	player_socket.cont_state = player_socket.ControlState.FULL
