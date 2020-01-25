extends Control


const IS_SERVER = false # is this a client or headless server?


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
	var _player_name_length = _player_name.length()
	if(_player_name_length < 1 || _player_name_length > 20):
		$InfoLabel.text ="Nickname should contain from 1 to 20 characters."
		return
	Global_Network.create_server(_player_name)
	_load_game()


func _on_JoinButton_pressed():
	var _player_name_length = _player_name.length()
	if(_player_name_length < 1 || _player_name_length > 20):
		$InfoLabel.text ="Nickname should contain from 1 to 20 characters."
		return
	Global_Network.connect_to_server(_player_name)
	_load_game()


func _load_game():
	get_tree().change_scene('res://Scenes/Game.tscn')
