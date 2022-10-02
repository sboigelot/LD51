extends KinematicBody

class_name Package

signal clicked(package)

export(NodePath) var rotation_root_np
onready var rotation_root = get_node(rotation_root_np) as Spatial

export(NodePath) var package_model_np
onready var package_model = get_node(package_model_np) as Spatial

export(NodePath) var tween_np
onready var tween = get_node(tween_np) as Tween

var target_basis: Basis
var rotation_speed: float = 200

var tween_basis: Basis setget set_tween_basis

func set_tween_basis(value:Basis):
	rotation_root.transform.basis = value

func rotate_cube(direction:Vector2):
	rotation_root.rotate_x(direction.x)
	rotation_root.rotate_z(direction.y)

func add_to_target_rotation(add_rotation: Vector2):

	var axis = Vector3(add_rotation.x/90, 0, add_rotation.y/90) # Or Vector3.RIGHT
	var rotation_radiant = deg2rad(90)
	
	target_basis = rotation_root.transform.basis.rotated(
		axis, rotation_radiant) #.orthonormalized()

	start_rotate_tween()

func start_rotate_tween():
	if tween.is_active():
		tween.stop_all()
		
	tween.interpolate_property(self, "tween_basis",
		rotation_root.transform.basis, target_basis, 0.2,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

#func _process(delta):
#	if Input.is_mouse_button_pressed(BUTTON_LEFT):
#		var mouse_postion = get_viewport().get_mouse_position() as Vector2
#
#		var camera = get_parent().get_parent().get_camera()
#		var from = camera.project_ray_origin(mouse_postion)
#		var to = from + camera.project_ray_normal(mouse_postion) * 100
##		var cursorPos = Plane(Vector3.UP, transform.origin.y).intersects_ray(from, to)
#		RayCast.new()
#		print(cursorPos)
#
func _on_Package_input_event(camera, event, position, normal, shape_idx):
	pass # Replace with function body.
