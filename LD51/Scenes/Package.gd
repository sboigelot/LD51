extends KinematicBody

class_name Package

signal clicked(package)
signal barcode_scanned(package, barcode)
signal scan_error(package, barcode)

export(NodePath) var package_model_np
export(NodePath) var tween_np
export(NodePath) var barcode_placeholder_np

onready var package_model = get_node(package_model_np) as Spatial
onready var tween = get_node(tween_np) as Tween
onready var barcode_placeholder = get_node(barcode_placeholder_np) as Spatial

var target_basis: Basis
var rotation_speed: float = 200

var tween_basis: Basis setget set_tween_basis

onready var barcodes_per_location = {
	Game.BARCODE_LOCATION.FRONT: 	$RotationRoot/BarcodesPlaceholder/FrontBarcode,
	Game.BARCODE_LOCATION.BACK: 	$RotationRoot/BarcodesPlaceholder/BottomBack,
	Game.BARCODE_LOCATION.LEFT: 	$RotationRoot/BarcodesPlaceholder/LeftBarcode,
	Game.BARCODE_LOCATION.RIGHT: 	$RotationRoot/BarcodesPlaceholder/RightBarcode,
	Game.BARCODE_LOCATION.TOP: 		$RotationRoot/BarcodesPlaceholder/TopBarcode,
	Game.BARCODE_LOCATION.BOTTOM: 	$RotationRoot/BarcodesPlaceholder/BottomBarcode,
}

var barcode: Barcode

func _ready():
	apply_barcode_location()
	
func apply_barcode_location():
	
	var random_location = Game.BARCODE_LOCATION.TOP
	if Game.barcode_location_per_product.has(filename):
		random_location = Game.barcode_location_per_product[filename]
	
	if barcodes_per_location.has(random_location):
		barcode = barcodes_per_location[random_location]
	else:
		barcode = barcodes_per_location[barcodes_per_location.keys()[0]]
	
	for other_barcode in barcodes_per_location.values():
		if other_barcode == barcode:
			continue
			
		other_barcode.queue_free()
	

func set_tween_basis(value:Basis):
	transform.basis = value

func rotate_cube(direction:Vector2):
	rotate_x(direction.x)
	rotate_z(direction.y)

func add_to_target_rotation(add_rotation: Vector2):

	var axis = Vector3(add_rotation.x/90, 0, add_rotation.y/90) # Or Vector3.RIGHT
	var rotation_radiant = deg2rad(90)
	
	target_basis = transform.basis.rotated(axis, rotation_radiant) #.orthonormalized()

	start_rotate_tween()

func start_rotate_tween():
	if tween.is_active():
		tween.stop_all()
		
	tween.interpolate_property(self, "tween_basis",
		transform.basis, target_basis, 0.2,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func _on_Package_input_event(camera, event, position, normal, shape_idx):
	if (event is InputEventMouseButton and
		event.pressed and
		event.button_index == BUTTON_LEFT):
			emit_signal("clicked", self)

func _on_Barcode_clicked(barcode):
	emit_signal("clicked", self)

func _on_Barcode_scanned(barcode):
	emit_signal("barcode_scanned", self, barcode)

func _on_Barcode_scan_error(barcode):
	emit_signal("scan_error", self, barcode)
