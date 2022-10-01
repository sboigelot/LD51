extends KinematicBody

class_name Package

export(NodePath) var package_model_np
onready var package_model = get_node(package_model_np) as Spatial

export(NodePath) var tween_np
onready var tween = get_node(tween_np) as Tween

var target_basis: Basis
var rotation_speed: float = 200

var tween_basis: Basis setget set_tween_basis

func set_tween_basis(value:Basis):
	package_model.transform.basis = value

func rotate_cube(direction:Vector2):
	package_model.rotate_x(direction.x)
	package_model.rotate_z(direction.y)

func add_to_target_rotation(add_rotation: Vector2):

	var axis = Vector3(add_rotation.x/90, 0, add_rotation.y/90) # Or Vector3.RIGHT
	var rotation_radiant = deg2rad(90)
	
	target_basis = package_model.transform.basis.rotated(
		axis, rotation_radiant) #.orthonormalized()

	start_rotate_tween()

func start_rotate_tween():
	if tween.is_active():
		tween.stop_all()
		
	tween.interpolate_property(self, "tween_basis",
		package_model.transform.basis, target_basis, 0.2,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()


func _on_Package_input_event(camera, event, position, normal, shape_idx):
	if(event.type == InputEvent.MOUSE_BUTTON and 
		event.button_index == 1 and 
		event.is_pressed() and !
		event.is_echo()):
		#assuming you want the object to move upwards:
		pass
#		self.set_linear_velocity(Vector2(0, -300))
