extends DungeonObject

## [button_sequence.gd] controller for a button sequence puzzle

@export var buttons: Array[DungeonButton] = []

var sequence_finished: bool = false

func _ready() -> void:
	# as of now dungeon buttons can only connect to one thing. This is pretty simple to change but
	# I don't feel like updating all the scenes where it's used so we're doing this instead yup
	if !sequence_finished:
		for button: DungeonButton in buttons:
			button.connect("on_triggered", Callable(self._on_button_triggered))
		
func _on_button_triggered(button_node: DungeonButton):
	if button_node.name == buttons[0].name:
		buttons.pop_front()
	
	if buttons.is_empty():
		print(">>> Button sequence finished! notified.")
		sequence_finished = true
		notify()
		
## Dungeon object methods
func serialize() -> Dictionary:
	return {"sequence_finished": sequence_finished}
	
func deserialize(state: Dictionary) -> void:
	sequence_finished = state["sequence_finished"]
