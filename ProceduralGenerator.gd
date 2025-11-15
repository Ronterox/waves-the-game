extends Node3D

class_name ProceduralGenerator

@export var size: int = 10
@export var frequency: float = 0.1
@export var amplitude: int = 10;

@export var chunk_size = 20
var rigid_bodies = {}

var player: Node3D
var multimesh_instance: MultiMeshInstance3D

var current_angle = 0
var camera: Camera3D

func generate() -> void:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(randf(), randf(), randf())

	# Create MultiMeshInstance3D
	multimesh_instance = MultiMeshInstance3D.new()
	var multimesh = MultiMesh.new()

	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = $Block/Mesh.mesh
	multimesh.instance_count = 0  # Will calculate exact count

	# First pass: count how many blocks we need
	var block_count = 0
	for i in size:
		var x = sin(i * frequency) * amplitude
		for k in size:
			var z = sin(k * frequency) * amplitude
			var surface = 1 + x + z
			for j in size:
				if j < surface:
					block_count += 1

	# Second pass: create transforms
	multimesh.instance_count = block_count
	var instance_index = 0

	for i in size:
		var x = sin(i * frequency) * amplitude
		for k in size:
			var z = sin(k * frequency) * amplitude
			var surface = 1 + x + z
			for j in size:
				if j < surface:
					var blockTransform = Transform3D.IDENTITY
					blockTransform.origin = Vector3(i, j, k)
					multimesh.set_instance_transform(instance_index, blockTransform)
					instance_index += 1

	multimesh_instance.multimesh = multimesh
	multimesh_instance.material_override = material
	add_child(multimesh_instance)

	# Hide original block
	$Block.hide()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().current_scene is ProceduralGenerator:
		camera = Camera3D.new()
		add_child(camera)
		camera.add_child(DirectionalLight3D.new())

	player = $"../Boat"
	generate()

func get_chunk_coords(pos: Vector3) -> Vector2:
	return Vector2(floor(pos.x / chunk_size), floor(pos.z / chunk_size))

func create_rigid_body_at(pos: Vector3):
	if rigid_bodies.has(pos):
		return
	rigid_bodies[pos] = true

	# Create a new RigidBody3D for dynamic physics
	var rigid_body = RigidBody3D.new()
	rigid_body.set_meta("is_clone", true)
	rigid_body.gravity_scale = 0

	# Create collision shape
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1, 1, 1)
	collision_shape.shape = box_shape
	# Create mesh instance for visualization
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = $Block/Mesh.mesh.duplicate()

	# Apply the same material if you want
	if multimesh_instance.material_override:
		mesh_instance.material_override = multimesh_instance.material_override

	# Add components to the rigid body
	rigid_body.add_child(collision_shape)
	rigid_body.add_child(mesh_instance)

	# Add to scene
	add_child(rigid_body)

	# Position the rigid body
	rigid_body.global_position = pos

func multimesh_to_rigidbody():
	var multimesh = multimesh_instance.multimesh

	for i in multimesh.instance_count:
		var transform = multimesh.get_instance_transform(i)
		var world_pos: Vector3 = global_transform * transform.origin

		# Check if this instance is within the chunk
		if get_chunk_coords(world_pos) == get_chunk_coords(player.global_position):
			create_rigid_body_at(world_pos)

		# Hide the multimesh instance (optional)
		multimesh.set_instance_transform(i, Transform3D())

func _process(delta: float) -> void:
	if player:
		var player_chunk = get_chunk_coords(player.global_position)
		var my_chunk = get_chunk_coords(global_position)
		if player_chunk == my_chunk:
			multimesh_to_rigidbody()

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

