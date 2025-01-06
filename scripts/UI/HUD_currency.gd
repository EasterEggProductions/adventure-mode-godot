extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Currently used for FPS counter
	$Label.text = "FPS " + str(Engine.get_frames_per_second())
