extends Control


@export var res_folder : String
@export var available_area : Control
@export var worn_area : Control

@export var dress_up_controller : Node

var all_garments = []

var created_buttons = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_resource_dir()
	make_garmet_buttons()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func make_garmet_buttons():
	clear_buttons()
	for garment in all_garments:
		var new_butt = Button.new()
		new_butt.text = garment.resource_name
		created_buttons.append(new_butt)
		if garment is Accessory:
			if is_instance_valid(dress_up_controller) && garment in dress_up_controller.accessories:
				new_butt.connect("pressed", self._garment_unequip.bind(garment))
				worn_area.add_child(new_butt)
			else: 
				new_butt.connect("pressed", self._garment_equip.bind(garment))
				available_area.add_child(new_butt)
		else:
			if is_instance_valid(dress_up_controller) && garment in dress_up_controller.garments:
				new_butt.connect("pressed", self._garment_unequip.bind(garment))
				worn_area.add_child(new_butt)
			else: 
				new_butt.connect("pressed", self._garment_equip.bind(garment))
				available_area.add_child(new_butt)

		#


func load_resource_dir():
	var dir = DirAccess.open(res_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
				pass
			else:
				print("Found file: " + file_name)
				#modules.append(load("res://Play_Resources/Modules/" + file_name))
				if '.tres.remap' in file_name: # <---- NEW
					file_name = file_name.trim_suffix('.remap') # <---- NEW
				var new_res = load(res_folder+ file_name)
				#print(new_res.name)
				all_garments.append(new_res)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func clear_buttons():
	for butt in created_buttons:
		butt.queue_free()
	created_buttons.clear()

func _garment_equip(gar):
	if gar is Accessory:
		dress_up_controller.accessory_equip(gar)
	else:
		dress_up_controller.garment_equip(gar)
	make_garmet_buttons()
	pass 

func _garment_unequip(gar):
	if gar is Accessory:
		dress_up_controller.accessory_unequip(gar)
	else:
		dress_up_controller.garment_unequip(gar)
	make_garmet_buttons()
	pass 