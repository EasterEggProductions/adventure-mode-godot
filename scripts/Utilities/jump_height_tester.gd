extends Node3D

@onready var actor := get_parent() as CharacterBody3D

var jump_start_pos: Vector3
var current_peak_y: float = -INF

var last_jump_height: float = 0.0
var max_jump_height: float = 0.0

var last_jump_distance: float = 0.0
var max_jump_distance: float = 0.0

var was_on_floor: bool = true

var label: Label


func _ready() -> void:
	_create_debug_ui()


func _physics_process(delta: float) -> void:
	if actor == null:
		return
	
	var pos := actor.global_position
	var on_floor := actor.is_on_floor()
	
	# Jump start
	if was_on_floor and not on_floor:
		jump_start_pos = pos
		current_peak_y = pos.y
	
	# Track peak height
	if not on_floor and pos.y > current_peak_y:
		current_peak_y = pos.y
	
	# Landing
	if not was_on_floor and on_floor:
		# Height
		last_jump_height = current_peak_y - jump_start_pos.y
		if last_jump_height > max_jump_height:
			max_jump_height = last_jump_height
		
		# Distance (XZ plane only)
		var horizontal_delta := pos - jump_start_pos
		horizontal_delta.y = 0.0
		last_jump_distance = horizontal_delta.length()
		
		if last_jump_distance > max_jump_distance:
			max_jump_distance = last_jump_distance
		
		#print(
			#"Height: ", last_jump_height,
			#" (max ", max_jump_height, ") | ",
			#"Dist: ", last_jump_distance,
			#" (max ", max_jump_distance, ")"
		#)
	
	was_on_floor = on_floor


func _process(delta: float) -> void:
	if label:
		label.text = (
			"Height\n  Last: %.2f\n  Max: %.2f\n\n" +
			"Distance\n  Last: %.2f\n  Max: %.2f"
		) % [
			last_jump_height, max_jump_height,
			last_jump_distance, max_jump_distance
		]


func _create_debug_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	
	label = Label.new()
	canvas.add_child(label)
	
	# Anchor top-right
	label.anchor_left = 1.0
	label.anchor_right = 1.0
	label.anchor_top = 0.0
	label.anchor_bottom = 0.0
	
	# Offset inward
	label.offset_right = -10
	label.offset_top = 10
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.text = "Jump Debug"
