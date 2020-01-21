extends Control


const IS_SERVER = false # is this a client or server?


var _player_name = ""


func _ready():
	set_process(false)
	set_process_input(false)
	
	if(IS_SERVER):
		Global_Network.create_server("")
		_load_game()

func _on_NameLineEdit_text_changed(new_text):
	_player_name = new_text


func _on_CreateButton_pressed():
	if _player_name == "":
		return
	Global_Network.create_server(_player_name)
	_load_game()


func _on_JoinButton_pressed():
	if _player_name == "":
		return
	Global_Network.connect_to_server(_player_name)
	_load_game()


func _load_game():
	get_tree().change_scene('res://Scenes/Game.tscn')
