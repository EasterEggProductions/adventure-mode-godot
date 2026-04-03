extends Timer


func _ready() -> void:
    timeout.connect(get_parent().queue_free)
    start(wait_time)