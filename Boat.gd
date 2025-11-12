extends CharacterBody3D

class_name Boat

# Boat settings
var max_speed = 15.0
var acceleration = 2.0
var deceleration = 1.5
var max_turn_speed = 1.0
var min_turn_speed = 0.3

# Current speed
var current_speed = 0.0

# Bobbing motion (always active)
var bob_time = 0.0
var bob_amount = 0.2
var bob_speed_max = 1.2
var bob_speed = 1.2

var anchor = true
signal anchored(anchor: bool)

func _ready() -> void:
	anchored.emit(true)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		anchored.emit(true)
	elif Input.is_action_just_pressed("ui_up"):
		anchored.emit(false)

func _physics_process(delta):
	# Get input from the Up/Down arrow keys
	# var move_input = Input.get_axis("ui_down", "ui_up")
	# Get input from the Left/Right arrow keys
	var turn_input = Input.get_axis("ui_left", "ui_right")
	
	if anchor:
		bob_speed *= 0.99
	
	var music: AudioStreamPlayer3D = $Music
	music.volume_db = music.max_db * current_speed * (current_speed / max_speed) - 30
	
	# Smoothly change speed
	# If we are pressing up or down, move towards our max speed.
	if not anchor:
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	# Otherwise, slow down to a stop.
	else:
		current_speed = move_toward(current_speed, 0.0, deceleration * delta)

	# This makes turning feel more realistic. The boat turns faster when it's moving fast.
	var speed_ratio = abs(current_speed) / max_speed
	var turn_speed = lerp(min_turn_speed, max_turn_speed, speed_ratio)

	# Apply the turn based on our input and calculated turn speed.
	rotate_y(turn_input * turn_speed * delta)

	# We want to move forward/backward, which is along the Z-axis of the boat.
	# The "-transform.basis.z" is Godot's way of saying "my local forward direction".
	velocity = -transform.basis.z * current_speed

	# --- Add some life with a bobbing motion! ---
	# We use a sine wave to create a smooth, repeating rocking motion.
	bob_time += delta * bob_speed
	var bob_intensity = lerp(bob_amount, bob_amount * 0.3, speed_ratio) # Rock less when moving fast
	# We get the boat model node and apply the rocking rotation to it directly.
	$Mesh.rotation.z = sin(bob_time) * bob_intensity

	# This is the magic function that actually moves our CharacterBody3D and handles collisions.
	move_and_slide()


func _on_anchored(is_anchor: bool) -> void:
	anchor = is_anchor
	if not anchor:
		bob_speed = bob_speed_max
