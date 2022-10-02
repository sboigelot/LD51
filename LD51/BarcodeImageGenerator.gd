extends Control

export(NodePath) var np_number_placeholder

onready var number_placeholder = get_node(np_number_placeholder) as Container

const number_and_line_scene = preload("res://Scenes/NumerAndLine.tscn")

func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func change_code(numbers:Array):
	delete_children(number_placeholder)
	
