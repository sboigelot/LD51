tool
extends VBoxContainer

export(int) var number setget set_number

func set_number(value:int):
	number = value
	$Label.text = var2str(value)
	$Label.visible = value > 0
	$MarginContainer/PanelContainer.rect_min_size.x = value if value > 0 else 3
