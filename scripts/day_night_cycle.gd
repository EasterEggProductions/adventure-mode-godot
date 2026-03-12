extends Node3D

@export var day_length: float = 30.0

@export var auto_run: bool = true

# I believe this is the only value needed for multiplayer sync. 
@export_range(0.0, 1.0) var time_of_day: float = 0.0


@onready var sun_pivot: Node3D = $SunPivot

@onready var sun: DirectionalLight3D = $SunPivot/DirectionalLight3D

@onready var world_env: WorldEnvironment = $WorldEnvironment


# Emitted whenever time_of_day changes.
signal time_changed(new_time)

# Emitted when crossing the sunrise threshold.
signal sunrise

# Emitted when crossing the sunset threshold.
signal sunset

# Stores previous frame time to detect transitions.
var _last_time: float = 0.0

# Initializes the sun's position when the node enters the scene tree. 
func _ready():
	_update_sun()

# Advances the day/night cycle every frame if the automatic time progression is enabled.
func _process(delta):
	if not auto_run:
		return

	_advance_time(delta)


# Time Control Functions

func _advance_time(delta: float):
	# Stores previous time for the transition detection.
	_last_time = time_of_day

	# Converts the real seconds into the normalized time progression.
	# delta / day_length determines fraction of full day passed.
	time_of_day += delta / day_length

	# Wraps the value between 0.0 and 1.0.
	time_of_day = fmod(time_of_day, 1.0)
 
	_check_transitions()

	# Updates the sun position to match the new time. 
	_update_sun()
	emit_signal("time_changed", time_of_day)

# Manually sets time of day (testing/cutscene use).
func set_time(value: float):
	_last_time = time_of_day

	# Clamp to the valid normalized range.
	time_of_day = clamp(value, 0.0, 1.0)

	_update_sun()
	emit_signal("time_changed", time_of_day)

# Changes how long a full day lasts.
func set_day_length(seconds: float):
	day_length = max(1.0, seconds)

# Stops automatic time progression.
func pause_cycle():
	auto_run = false

# Resumes automatic time progression.
func resume_cycle():
	auto_run = true


# Sun Logic

# Updates the sun's rotation based on normalized time.
# 0.0 = 0 degrees, 1.0 = 360 degrees.
func _update_sun():
	var angle = time_of_day * 360.0

	# Sun rotation.
	sun_pivot.rotation_degrees.x = angle


# Transition Checks 

func _check_transitions():
	# Sunrise threshold.
	if _last_time < 0.25 and time_of_day >= 0.25:
		emit_signal("sunrise")

	# Sunset threshold.
	if _last_time < 0.75 and time_of_day >= 0.75:
		emit_signal("sunset")
