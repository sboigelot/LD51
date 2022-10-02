extends Control

export(NodePath) var np_number_placeholder

onready var number_placeholder = get_node(np_number_placeholder)

const number_and_line_scene = preload("res://Scenes/NumerAndLine.tscn")

export(PoolIntArray) var code

export var stained: bool

func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
		
func change_code(numbers:PoolIntArray, stained:bool):
	code = numbers
	delete_children(number_placeholder)
	
	var instance = number_and_line_scene.instance()
	instance.number = -1
	number_placeholder.add_child(instance)
		
	for number in numbers:
		instance = number_and_line_scene.instance()
		instance.number = number
		number_placeholder.add_child(instance)
	
	instance = number_and_line_scene.instance()
	instance.number = -1
	number_placeholder.add_child(instance)
	
	$PanelContainer/ForegroundTextureRect.visible = stained
