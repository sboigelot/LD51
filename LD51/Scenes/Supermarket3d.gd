extends Spatial

class_name Supermarket3d

var scan_package: Package

export(NodePath) var scan_package_holder_np
onready var scan_package_holder = get_node(scan_package_holder_np) as Spatial
export(Vector3) var package_scale_on_belt = Vector3(0.75,0.75,0.75)
export(float) var conveyor_speed = 60.0

const package_scene = preload("res://Scenes/Package.tscn")

onready var camera = $Camera as Camera
onready var scan_camera = $ScanViewport/ScanCamera as Camera

func _on_Supermarket_rotate_package(add_rotation):
	rotate_package(add_rotation)
	
func rotate_package(add_rotation: Vector2):
	if scan_package == null:
		return
	scan_package.add_to_target_rotation(add_rotation)
	
func _ready():
	if scan_package_holder.get_child_count() >= 1:
		scan_package = scan_package_holder.get_child(0)
	spawn_package()
	
func _on_Timer_timeout():
	spawn_package()
	
func spawn_package():
	var instance = package_scene.instance()
	var spawn_positions = [
		$ConveyorBelt/PackageSpawnLocations/Location1.transform,
		$ConveyorBelt/PackageSpawnLocations/Location2.transform,
		$ConveyorBelt/PackageSpawnLocations/Location3.transform,
		$ConveyorBelt/PackageSpawnLocations/Location4.transform,
	]
	instance.transform = spawn_positions[randi() % spawn_positions.size()]
	instance.connect("clicked", self, "on_conveyor_belt_package_clicked")
	
#	Rotate randomly
	var axis = Vector3.UP
	var rotation_radiant = deg2rad(randi() % 360)
	instance.transform.basis = instance.transform.basis.rotated(axis, rotation_radiant)
	
#	scale
	instance.scale = package_scale_on_belt
	$ConveyorBelt.add_child(instance)

func on_conveyor_belt_package_clicked(package: Package):
	if scan_package_holder.get_child_count() == 0:
		package.get_parent().remove_child(package)
		scan_package_holder.add_child(package)
		package.disconnect("clicked", self, "on_conveyor_belt_package_clicked")
		package.transform = Transform()
		scan_package = package

func _physics_process(delta):

	var direction = Vector3.RIGHT
	var velocity = direction * conveyor_speed
		
	for child in $ConveyorBelt.get_children():
		if child is Package:
			var package = child as Package
			package.move_and_slide(velocity * delta)

func _process(delta):
	move_scan_camera()
	
func move_scan_camera():
	var x_extremes = [ -9, +9]
	var x_range = 18.0
	var y_extremes = [-5, +5]
	var y_range = 10.0
	var mouse_postion = get_viewport().get_mouse_position() as Vector2

	scan_camera.translation.x = mouse_postion.x / OS.window_size.x * x_range - x_range /2
	scan_camera.translation.z = mouse_postion.y / OS.window_size.y * y_range - y_range /2

#	scan_camera.translation.x = mouse_postion.x / OS.window_size.x * (camera.size / 1) - (camera.size)
#	scan_camera.translation.z =  mouse_postion.y # / OS.window_size.y * (camera.size / 2) - (camera.size / 2)
