extends Node3D

@export var SIZE = 10
var current_angle = 0

func randb() -> bool:
	return randi_range(0, 1) as bool


func generate() -> void:
	var block: StaticBody3D = $Block
	for i in SIZE:
		for j in SIZE:
			for k in SIZE:
				var surface = 1 + sin(k) * SIZE
				if randb() or j < surface:
					var b: StaticBody3D = block.duplicate()
					b.position = Vector3(i, j, k)
					b.set_meta("is_clone", true)
					add_child(b)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		for child in get_children():
			if child.get_meta("is_clone", false):
				child.queue_free()
		generate()
	
	const distance = 15
	const rotation_speed = 1
	const height = 10
	current_angle += rotation_speed * delta
	
	# Calculate camera position using spherical coordinates
	var camera_pos = Vector3(
		sin(current_angle) * distance,
		height,
		cos(current_angle) * distance
	)
	
	# Set camera position
	$Camera3D.position = camera_pos
	
	# Make camera look at target
	$Camera3D.look_at($Block.global_position)
