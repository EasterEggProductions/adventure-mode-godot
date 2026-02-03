extends Button

@export var menu : PackedScene
@export var parent_menu : Menu

func _ready() -> void:
	connect("pressed", Callable(self, "open_menu"))

func open_menu():
	parent_menu.open_submenu(menu)