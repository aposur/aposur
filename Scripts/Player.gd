extends Area2D

export (int) var speed = 200

var velocity = Vector2()

puppet var slave_position = Vector2()
puppet var slave_movement = Vector2(0.0, 0.0)

var is_other_focused = false setget set_is_other_focused, get_is_other_focused

onready var _inventory = $Inventory
onready var _inventory_button = $InventoryButton

var _data_player:Dictionary
#onready var _data_player:Dictionary = Dictionary()

var bag


func _ready():
	set_process(false)
	set_process_input(true)
	
	if(!is_network_master()):
		for child in get_children():
			if child.has_method('hide'):
				child.hide()
		$Sprite.visible = true
		$NicknameLabel.visible = true

func _input(event):
	if(is_other_focused):
		velocity = Vector2(0.0, 0.0)
		return
		
	if is_network_master():
		if event is InputEventScreenTouch:
			if event.is_pressed():
				velocity = get_local_mouse_position().normalized()
			else:
				velocity = Vector2(0.0, 0.0)
		elif event is InputEventScreenDrag:
			velocity = get_local_mouse_position().normalized()
		elif event is InputEventKey:
			velocity = Vector2(0.0, 0.0)
			if Input.is_action_pressed('ui_right'):
				velocity.x += 1
			if Input.is_action_pressed('ui_left'):
				velocity.x -= 1
			if Input.is_action_pressed('ui_down'):
				velocity.y += 1
			if Input.is_action_pressed('ui_up'):
				velocity.y -= 1
			if Input.is_action_pressed('die'):
#				rpc("_die_and_loose_items", $NicknameLabel.text, _data_player, $Sprite.global_position)
				_die_and_loose_items($NicknameLabel.text, _data_player, $Sprite.global_position)
		
		velocity = velocity.normalized()
	else:
		position = slave_position
	
	rset_unreliable('slave_position', position)
#	rset('slave_movement', velocity)
	
	if get_tree().is_network_server():
		Global_Network.update_position(int(name), position)


func _physics_process(delta):
	if(velocity && speed):
		position += velocity * delta * speed


func init(nickname, start_position, is_slave):
	$NicknameLabel.text = nickname
	_data_player = load_items(nickname, "Player")
	
	position = start_position
	rset_unreliable('slave_position', position)
	
#	if is_slave:
#		$Sprite.texture = load('res://player/character-alt.png')
	if is_network_master():
		$Camera2D.current = 1


func _die_and_loose_items(nickname:String, data:Dictionary, die_position:Vector2):
#	$RespawnTimer.start()
	set_physics_process(false)
	for child in get_children():
		if child.has_method('hide'):
			child.hide()
	if(is_network_master()):
#		rset("nickname", nickname)
#		print(var2str(data))
#		rpc("rpc_spawn_bag", nickname, data, die_position)
		rpc_spawn_bag(nickname, data, die_position)
#		rpc("rpc_clear_items", nickname, "Player")
		rpc_clear_items(nickname, "Player")


func rpc_spawn_bag(nickname:String, data:Dictionary, die_position:Vector2) -> void:
	if(is_network_master()):
		rpc("spawn_bag", nickname, data, die_position)
	


sync func spawn_bag(nickname:String, data:Dictionary, die_position:Vector2) -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		bag = load('res://Scenes/Bag.tscn').instance()
		bag.name = nickname + "_" + str(Global_DataParser.rng.randi())
		$'/root/Game/'.add_child(bag)
		bag.init(_inventory, bag.name, data, die_position)


func remove_bag_by_area2d(area) -> void:
	area.get_parent().rpc_destroy_self()


func set_is_other_focused(is_focused) -> void:
	is_other_focused = is_focused


func get_is_other_focused() -> bool:
	return is_other_focused


sync func load_items(name, item_list_label:String = "Player") -> Dictionary:
	return _inventory.load_data(name, item_list_label)


func rpc_clear_items(name, item_list_label:String = "Player") -> void:
	rpc("clear_items", name, item_list_label)


remote func clear_items(name, item_list_label:String = "Player") -> Dictionary:
	return _inventory.load_data(name, item_list_label, true)


func show_info(text:String):
	$InfoLabel.text = text
	$InfoLabel.visible = true
	
	var timer = $InfoTimer
	timer.connect("timeout",self,"_on_timer_show_info_timeout")
	timer.wait_time = 5
	timer.one_shot = false
	add_child(timer) #to process
	timer.start() #to start


func _on_timer_show_info_timeout():
	$InfoLabel.text = ""
	$InfoLabel.visible = false


func _on_Player_area_entered(area):
	if(area.is_in_group("shops")):
		_inventory_button.modulate = Color(1,1,0,0.5)
		_inventory.set_other_visible(true)
		load_items(area.name, "Shop")
		_inventory.button_multi.text = "Sell"
	elif(area.is_in_group("bags")):
		_inventory_button.modulate = Color(1,1,0,0.5)
		_inventory.set_other_visible(true)
		load_items(area.get_parent().name, "Bag")
		_inventory.button_multi.text = "Take"


func _on_Player_area_exited(area):
	_inventory_button.modulate = Color(1,1,1,0.5)
	_inventory.button_multi.text = "Drop"
	_inventory.set_other_visible(false)
	if(area.is_in_group("bags")):
#		if(get_tree().is_network_server()):
#			rset("_inventory",_inventory)
		area.get_parent().reload_data()
		if(area.get_parent().is_data_empty_by_inventory(_inventory)):
			remove_bag_by_area2d(area)

func _on_InventoryButton_pressed():
	if(_inventory.is_visible()):
		_inventory.visible = false
		set_is_other_focused(false)
	else:
		_inventory.visible = true
		set_is_other_focused(true)


func _on_InventoryButton_mouse_entered():
	_inventory_button.modulate = Color(1, 1, 1, 1)


func _on_InventoryButton_mouse_exited():
	if(!_inventory.is_visible()):
		_inventory_button.modulate = Color(1, 1, 1, 0.5)
