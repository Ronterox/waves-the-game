extends Node3D

class_name ProceduralGenerator

@export var SIZE: int = 10
@export var frecuency: float = 0.1
@export var amplitude: int = 10;

var current_angle = 0
var camera: Camera3D

func generate() -> void:
	var block: RigidBody3D = $Block
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(randf(), randf(), randf())
	$Block/Mesh.material_override = material

	for i in SIZE:
		var x = sin(i * frecuency) * amplitude
		for k in SIZE:
			var z = sin(k * frecuency) * amplitude
			var surface = 1 + x + z
			for j in SIZE:
				if j < surface:
					var b: RigidBody3D = block.duplicate()
					b.position = Vector3(i, j, k)
					b.set_meta("is_clone", true)
					add_child(b)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().current_scene is ProceduralGenerator:
		camera = Camera3D.new()
		add_child(camera)
		camera.add_child(DirectionalLight3D.new())
	generate()

func _process(delta: float) -> void:
	if not camera:
		return

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
	camera.position = camera_pos

	# Make camera look at target
	camera.look_at($Block.global_position)

	if Input.is_action_just_pressed("ui_accept"):
		for child in get_children():
			if child.get_meta("is_clone", false):
				child.queue_free()
		generate()
