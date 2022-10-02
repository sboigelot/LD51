extends Spatial

class_name Supermarket3d

export(NodePath) var scan_package_np
onready var scan_package = get_node(scan_package_np) as Package
export(Vector3) var package_scale_on_belt = Vector3(0.75,0.75,0.75)
export(float) var conveyor_speed = 60.0

onready var camera = $CameraHead/Camera as Camera
onready var raycast = $CameraHead/RayCast as RayCast

const package_scene = preload("res://Scenes/Package.tscn")

func rotate_package(add_rotation: Vector2):
	scan_package.add_to_target_rotation(add_rotation)

func get_camera():
	return $Camera

func _on_Timer_timeout():
	var instance = package_scene.instance()
	var spawn_positions = [
		$PackageSpawnLocations/Location1.transform,
		$PackageSpawnLocations/Location2.transform,
		$PackageSpawnLocations/Location3.transform,
		$PackageSpawnLocations/Location4.transform,
	]
	instance.transform = spawn_positions[randi() % spawn_positions.size()]
	
#	Rotate randomly
	var axis = Vector3.UP
	var rotation_radiant = deg2rad(randi() % 360)
	instance.transform.basis = instance.transform.basis.rotated(axis, rotation_radiant)
	
#	scale
	instance.scale = package_scale_on_belt
	$ConveyorBelt.add_child(instance)
	
func _physics_process(delta):
	
	var direction = Vector3.RIGHT
	var velocity = direction * conveyor_speed
		
	for child in $ConveyorBelt.get_children():
		var package = child as Package
		package.move_and_slide(velocity * delta)

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		pass
		
		var mouse_postion = get_viewport().get_mouse_position() as Vector2
		
#		raycast.translation.x = mouse_postion.x / OS.window_size.x * camera.size
#		raycast.translation.z = mouse_postion.y / OS.window_size.y * camera.size
		
		if raycast.is_colliding():
			pass
		
		
