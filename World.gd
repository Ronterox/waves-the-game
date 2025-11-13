extends WorldEnvironment

var scene: PackedScene

func generate_world(structures: int) -> void:
	for i in range(structures):
		var x = randi() % 500 - 500
		var z = randi() % 500 - 500
		var obj: ProceduralGenerator = scene.instantiate()
		obj.position = Vector3(x, 0, z)
		obj.SIZE = randi_range(3, 30)
		obj.amplitude = randi_range(3, 20)
		obj.frecuency = randf_range(0.1, 1)
		add_child(obj)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene = preload("res://ProceduralGenerator.tscn")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		generate_world(2)
	elif Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
