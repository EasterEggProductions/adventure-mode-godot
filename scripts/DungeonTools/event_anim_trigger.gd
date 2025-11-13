extends DungeonEntity

@onready var _anim_player = $AnimationPlayer

@export var toggle_button: DungeonButton = null
@export var animation : String
@export var one_shot = true
@export var locked = false

var shot = false 

func _init() -> void:
	if toggle_button:
		toggle_button.connect("button_pressed", Callable(open_door))

func open_door():
	_anim_player.play(animation)


func trigger_animation(body):
	if locked:
		return
	# Dirty check for player 
	print(name)
	if !body.is_in_group("players"):
		return
	if one_shot == false:
		open_door()
	elif shot == false:
		shot = true
		open_door()
