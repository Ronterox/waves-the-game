extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var speed = $"../Boat".current_speed
	$MarginContainer/Speed.text = "%.2f m/s" % speed


func _on_boat_anchored(anchor: bool) -> void:
	$MarginContainer/State.text = "Anchored." if anchor else "Boating..."
