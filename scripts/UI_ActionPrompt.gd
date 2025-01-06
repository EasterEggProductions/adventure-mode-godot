extends Control

@export var output : RichTextLabel

var action_button = "Y"

var action_name = "Take"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func show_prompt(item : String):
	if action_name == item:
		return
	var message = "[center]" + "[b][color=yellow]" + action_button + "[/color][/b] " + item + "[/center]"
	output.text = message
	action_name = item

func hide_prompt():
	action_name = ""
	output.text = ""