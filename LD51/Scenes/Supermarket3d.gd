extends Spatial

class_name Supermarket3d

export(NodePath) var scan_package_np
onready var scan_package = get_node(scan_package_np) as Package

const package_scene = preload("res://Package.tscn")

func rotate_package(add_rotation: Vector2):
	scan_package.add_to_target_rotation(add_rotation)

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
	
	$ConveyorBelt.add_child(instance)
	
func _physics_process(delta):
	
	var direction = Vector3.RIGHT
	var speed = 30.0
	var velocity = direction * speed
		
	for child in $ConveyorBelt.get_children():
		var package = child as Package
		package.move_and_slide(velocity * delta)
