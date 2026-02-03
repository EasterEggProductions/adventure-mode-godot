extends Control

class_name Menu

var parent_menu : Menu # Probably a button, but whoever it was needs to accept close_menu
var child_menu : Menu

## This button will be back or quit if this is the root menu. 
@export var close_button : Button 
## This button will be the default button to focus when the menu opens
@export var focus_button : Button
## If set the open and close animations will be used
@export var anim : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_instance_valid(close_button):
		if is_instance_valid(parent_menu):
			close_button.text = "Back"
		else:
			close_button.text = "Quit"
		close_button.connect("pressed", Callable(self, "back_button"))
	#focus()
	if is_instance_valid(focus_button):
		focus_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if is_instance_valid(parent_menu):
			back_button()


func back_button():
	if is_instance_valid(parent_menu):
		parent_menu.close_menu()
	else:
		get_tree().quit()

func open_submenu(submenu : PackedScene) -> void:
	child_menu = submenu.instantiate() as Menu
	child_menu.parent_menu = self
	get_parent().add_child(child_menu)
	_anim_close()
	if is_instance_valid(anim):
		await anim.animation_finished
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	child_menu._anim_open()
	child_menu.focus()

func close_menu():
	child_menu._anim_close()
	if is_instance_valid(child_menu.anim):
		await child_menu.anim.animation_finished
	child_menu.queue_free()
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	_anim_open()
	focus()



func focus():
	if is_instance_valid(focus_button):
		focus_button.grab_focus()
	else:
		for child in get_children():
			if child is Button && child.visible == true && child.disabled == false:
				child.grab_focus()
				return


func _anim_open():
	if is_instance_valid(anim):
		anim.play("open")
		await anim.animation_finished
	else:
		var tween = get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		await tween.tween_property(self, "modulate", Color.WHITE, 0.1).finished


func _anim_close():
	if is_instance_valid(anim):
		anim.play("close")
		await anim.animation_finished
	else: 
		var tween = get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		await tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.1).finished
	#queue_free()
