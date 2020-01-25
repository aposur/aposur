extends Control


onready var _player = get_parent()
onready var _chat_input = $Panel/LineEdit
onready var _chat_display = $Panel/RichTextLabel


func _ready():
	set_process(false)
	set_process_input(false)
	
	_chat_display.set_scroll_follow(true)
	
#	get_tree().connect("connection_failed", self, "_user_failed") # not working, maybe someone can fix this
#	get_tree().connect("connection_succeded", self, "_host_room") # not working, maybe someone can fix this
	get_tree().connect("connected_to_server", self, "_enter_room")
	get_tree().connect("network_peer_connected", self, "_user_entered")
	get_tree().connect("network_peer_disconnected", self, "_user_exited")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	if(_player.name == "1"):
		_host_room()


func _server_disconnected():
	_chat_display.text += "Disconnected from Server\n"
	_leave_room()


func _user_entered(id):
	_chat_display.text += str(id) + " joined the room\n"


func _user_exited(id):
	_chat_display.text += str(id) + " left the room\n"


func _host_room():
	_chat_display.text += "Room Created\n"
	_enter_room()


func _user_failed():
	_chat_display.text += "Connection failed\n"


func _enter_room():
	_chat_display.text += "Successfully joined room\n"


func _leave_room():
	get_tree().set_network_peer(null)
	_chat_display.text += "Left Room\n"


func _send_message(msg):
	_chat_input.text = ""
	rpc("receive_message", _player.name, _player.get_node("NicknameLabel").text, msg)


sync func receive_message(id, player_name, msg):
	for player in get_tree().get_nodes_in_group("players"):
		if(!msg.empty()):
			player.get_node("Chat").get_node("Panel").get_node("RichTextLabel").text += str(player_name) + ": " + msg + "\n"


func _on_LineEdit_focus_entered():
	_player.set_is_other_focused(true)


func _on_LineEdit_focus_exited():
	_player.set_is_other_focused(false)


func _on_LineEdit_text_entered(new_text):
	_send_message(new_text)
	_chat_input.release_focus()


func _on_Button_pressed():
	_on_LineEdit_text_entered(_chat_input.text)
