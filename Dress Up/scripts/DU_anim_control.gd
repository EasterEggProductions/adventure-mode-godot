extends Control

@export var anim : AnimationPlayer

@export var layout_area : Control

var created_buttons = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_animation_buttons()
	anim.play("walk_fwd")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func make_animation_buttons():
	clear_buttons()
	#anim.get_animation_library_list()
	#var animLib = anim.get_animation_library("lib")
	#animLib.get_animation_list()
	for anim in anim.get_animation_list():
		var new_butt = Button.new()
		new_butt.text = anim
		created_buttons.append(new_butt)
		layout_area.add_child(new_butt)
		new_butt.connect("pressed", self._play_anim_from_button.bind(anim))

func clear_buttons():
	for butt in created_buttons:
		butt.queue_free()
	created_buttons.clear()


func _play_anim_from_button(name : String):
	print(name)
	anim.play(name)