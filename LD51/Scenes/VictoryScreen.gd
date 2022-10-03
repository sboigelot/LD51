extends Control

export(NodePath) var np_victory_label
export(NodePath) var np_submit_button
export(NodePath) var np_retry_button
export(NodePath) var np_score_label
export(NodePath) var np_time_label
export(NodePath) var np_top_score_rtb
export(NodePath) var np_top_time_rtb
export(NodePath) var np_post_score_dialog
export(NodePath) var np_post_score_name_lineedit

onready var victory_label = get_node(np_victory_label) as Label
onready var submit_button = get_node(np_submit_button) as Button
onready var retry_button = get_node(np_retry_button) as Button
onready var score_label = get_node(np_score_label) as Label
onready var time_label = get_node(np_time_label) as Label
onready var top_score_rtb = get_node(np_top_score_rtb) as RichTextLabel
onready var top_time_rtb = get_node(np_top_time_rtb) as RichTextLabel
onready var post_score_dialog = get_node(np_post_score_dialog) as AcceptDialog
onready var post_score_name_lineedit = get_node(np_post_score_name_lineedit) as LineEdit

var reloading_leaderboard: bool = false
var score_submitted = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	update_ui(Game.win, Game.score, Game.time)
	
	Leaderboard.connect("entry_added", self, "on_score_added")
	Leaderboard.connect("error", self, "on_leaderboard_error")
	Leaderboard.connect("top_score_updated", self, "on_leaderboard_score_updated")
	Leaderboard.connect("top_time_updated", self, "on_leaderboard_time_updated")
	
	submit_button.disabled = true
	
	update_top_score_ui()
	update_top_time_ui()
	reload_leaderboard()
	
func update_top_score_ui():
	top_score_rtb.bbcode_text = "[center][b]TOP 10 SCORES[/b]\n"
	
	for entry in Leaderboard.top_score:
		top_score_rtb.bbcode_text += "\n%s\t%s[img=32]res://Sprites/coin.png[/img]" % [
			entry.name,
			entry.score
		]
	
	top_score_rtb.bbcode_text += "[/center]"
	
func update_top_time_ui():
	top_time_rtb.bbcode_text = "[center][b]TOP 10 TIMES[/b]\n"
	
	for entry in Leaderboard.top_time:
		top_time_rtb.bbcode_text += "\n%s\t%s" % [
			entry.name,
			Game.to_time_str(int(entry.time))
		]
	
	top_time_rtb.bbcode_text += "[/center]"
	
func reload_leaderboard():
	reloading_leaderboard = true
	Leaderboard.get_top_score()
	
func update_ui(win:bool, score:int, time:float):
	victory_label.text = "Victory" if win else "You are Fired!"
	retry_button.visible = true #not win
	
	score_label.text = "%d" % score
	
	var seconds = floor(Game.time)
	var minutes = floor(seconds / 60)
	seconds -= minutes * 60
	var miliseconds = round((Game.time - seconds)*10)
	time_label.text = "%02d:%02d:%02d" % [
		minutes,
		seconds,
		miliseconds
	] 

func _on_BackToMenuButton_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

func _on_RetryButton_pressed():
	Game.new_game()

func on_score_added():
	reload_leaderboard()
	
func on_leaderboard_error():
	printerr("Error loading leaderboard")
	top_time_rtb.bbcode_text = "[center][b]TOP 10 TIMES[/b]\n\nserver offline[/center]"
	top_score_rtb.bbcode_text = "[center][b]TOP 10 SCORES[/b]\n\nserver offline[/center]"
	
func on_leaderboard_score_updated():
	Leaderboard.get_top_time()
	update_top_score_ui()
	
func on_leaderboard_time_updated():
	reloading_leaderboard = false
	
	submit_button.disabled = score_submitted
	on_leaderboard_loaded()
	
func on_leaderboard_loaded():
	update_top_time_ui()


func _on_PostScoretDialog_confirmed():
	if post_score_name_lineedit.text == "":
		return
		
	submit_button.disabled = true
	score_submitted = true
	Leaderboard.post_entry(
		post_score_name_lineedit.text,
		Game.score,
		int(Game.time)
	)

func _on_PostScoreButton_pressed():
	post_score_dialog.popup_centered()
