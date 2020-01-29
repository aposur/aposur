extends Control


const INVENTORY_MAX_SLOTS = 30


onready var _item_list_1 = $Panel/ItemList
onready var _item_list_2 = $Panel/ItemList2

onready var _item_list_label_1 = $Panel/ItemListLabel
onready var _item_list_label_2 = $Panel/ItemList2Label

var url_data_player
var url_data_other
var url_data:String

puppet var data_player:Dictionary
puppet var data_other:Dictionary

onready var button_multi = $Panel/Button


func _ready():
	set_process(false)
	set_process_input(false)
	
	visible = false
	_item_list_2.visible = false
	_item_list_label_2.visible = false
	set_center_item_visible(false)


func load_data(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	
	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	
	if(is_save_data):
		Global_DataParser.write_data(url_data, data_save)
	
	var data:Dictionary = Global_DataParser.load_data(url_data)
	
	if (data.empty() || is_clear_items && !is_save_data):
		var dict:Dictionary = {"inventory":{}}
		for slot in range (0, INVENTORY_MAX_SLOTS):
			if(int(slot) == 0 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 1000}
			elif(int(slot) == 1 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 1}
			elif(int(slot) == 2 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 10}
			elif(int(slot) == 0 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 1000}
			elif(int(slot) == 1 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 10}
			elif(int(slot) == 2 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 1000}
			elif(int(slot) == 3 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "4", "amount": 1}
			else:
				dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
		Global_DataParser.write_data(url_data, dict)
		data = dict
	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data


func load_items(item_list:Control = _item_list_1, data:Dictionary = data_player) -> Dictionary:
	var selected_items = item_list.get_selected_items()
	var slot_id
	if(selected_items): # check if item was selected before reloading items
		slot_id = selected_items[0]
	
	item_list.clear()
	for slot in range(0, INVENTORY_MAX_SLOTS):
		item_list.add_item("", null, false)
		update_slot(slot, item_list, data)
	
	if(slot_id != null): # item was selected before reloading so lets reselect it
		_item_list_1.select(slot_id)
		_on_ItemList_item_selected(slot_id)
#		_update_center_item(slot_id, item_list, _get_item_id_from_slot_id(slot_id, data))
	return data


func unload_items(filename:String, item_list_label:String = "Player") -> void:
	load_data(filename, item_list_label, true)

func update_slot(slot:int, item_list, data) -> void:
	if (slot < 0):
		return
	var inventory_item:Dictionary = data.inventory[str(slot)]
	var item_meta_data = Global_ItemDatabase.get_item(str(inventory_item["id"])).duplicate()
	var icon = ResourceLoader.load(item_meta_data["icon"])
	var amount = int(inventory_item["amount"])
	
	item_meta_data["amount"] = amount
	if (!item_meta_data["stackable"]):
		amount = " " 
	item_list.set_item_text(slot, String(amount))
	item_list.set_item_icon(slot, icon)
	item_list.set_item_selectable(slot, int(inventory_item["id"]) > 0)
	item_list.set_item_metadata(slot, item_meta_data)
	item_list.set_item_tooltip(slot, item_meta_data["name"])
	item_list.set_item_tooltip_enabled(slot, int(inventory_item["id"]) > 0)


func _update_center_item(slot_id, item_list, item_id:int):
	var item_meta_data = Global_ItemDatabase.get_item(str(item_id)).duplicate()
	$Panel/ItemNameLabel.text = item_list.get_item_tooltip(slot_id)
	$Panel/ItemSprite.texture = item_list.get_item_icon(slot_id)
	$Panel/ItemCountLabel.text = item_list.get_item_text(slot_id)
	$Panel/ItemDescriptionRichTextLabel.text = item_meta_data["description"]
	$Panel/ItemPriceLabel.text = "Price: " + var2str(stepify(float(item_meta_data["sell_price"]), 0.01)).pad_decimals(2)
	$Panel/ItemWeightLabel.text = "Weight: " + var2str(stepify(float(item_meta_data["weight"]), 0.01)).pad_decimals(2) + "kg"
	$Panel/LineEdit.text = item_list.get_item_text(slot_id)
	$Panel/HSlider.max_value = float(item_list.get_item_text(slot_id))
	$Panel/HSlider.value = float(item_list.get_item_text(slot_id))
	$Panel/HSlider.tick_count = int(item_list.get_item_text(slot_id)) / 10 + 2


func set_center_item_visible(is_center_item_visible):
	$Panel/ItemNameLabel.visible = is_center_item_visible
	$Panel/ItemSprite.visible = is_center_item_visible
	$Panel/ItemCountLabel.visible = is_center_item_visible
	$Panel/ItemDescriptionRichTextLabel.visible = is_center_item_visible
	$Panel/ItemPriceLabel.visible = is_center_item_visible
	$Panel/ItemWeightLabel.visible = is_center_item_visible
	$Panel/LineEdit.visible = is_center_item_visible
	$Panel/HSlider.visible = is_center_item_visible
	button_multi.visible = is_center_item_visible


func set_other_visible(is_visible):
	_item_list_2.clear()
	_item_list_label_2.visible = is_visible
	_item_list_2.visible = is_visible


func get_item_price(item_id:int) -> float:
	var item_meta_data = Global_ItemDatabase.get_item(str(item_id))
	return float(item_meta_data["sell_price"])


func get_item_meta_data(item_id:int) -> Dictionary:
	var item_meta_data = Global_ItemDatabase.get_item(str(item_id))
	return item_meta_data


func get_money_by_data(data) -> float:
	var money:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS):
		if(int(data.inventory[str(slot)]["id"]) == 1):
			money += float(data.inventory[str(slot)]["amount"])
	return money


func get_weight() -> float:
	var weight:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS):
		var item_id:int = int(data_player.inventory[str(slot)]["id"])
		var item_meta_data:Dictionary = get_item_meta_data(item_id)
		if(str(item_meta_data["type"]) != "vehicle"):
			weight += float(item_meta_data["weight"]) * float(int(data_player.inventory[str(slot)]["amount"]))
	return weight


func get_max_weight() -> float:
	var max_weight:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS):
		var item_id:int = int(data_player.inventory[str(slot)]["id"])
		var item_meta_data:Dictionary = get_item_meta_data(item_id)
		if(str(item_meta_data["type"]) == "vehicle"):
			max_weight += float(item_meta_data["max_weight"])
	return max_weight



func get_water() -> float:
	var water:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS):
		if(int(data_player.inventory[str(slot)]["id"]) == 3):
			water += float(data_player.inventory[str(slot)]["amount"])
	return water


func get_food() -> float:
	var food:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS):
		if(int(data_player.inventory[str(slot)]["id"]) == 1):
			food += float(data_player.inventory[str(slot)]["amount"])
	return food


func get_vehicles_min_speed() -> float:
	var min_speed:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS):
		var item_id:int = int(data_player.inventory[str(slot)]["id"])
		var item_meta_data:Dictionary = get_item_meta_data(item_id)
		if(str(item_meta_data["type"]) == "vehicle"):
			if(int(min_speed) > int(item_meta_data["max_speed"]) || int(min_speed) == 0):
				min_speed = float(item_meta_data["max_speed"])
	return min_speed


func remove_item_amount_by_id(item_id:int, amount:float, data:Dictionary) -> Dictionary:
	for slot in range (0, INVENTORY_MAX_SLOTS):
		if(int(data.inventory[str(slot)]["id"]) == item_id):
			data.inventory[str(slot)]["amount"] = float(data.inventory[str(slot)]["amount"])
			if(data.inventory[str(slot)]["amount"] < amount):
				amount = amount - data.inventory[str(slot)]["amount"]
				data.inventory[str(slot)]["amount"] = 0.00
				data.inventory[str(slot)]["id"] = "0"
			else:
				data.inventory[str(slot)]["amount"] = data.inventory[str(slot)]["amount"] - amount
				if(data.inventory[str(slot)]["amount"] <= 0):
					data.inventory[str(slot)]["id"] = "0"
				break
	return data


func minus_money(amount:float, data:Dictionary) -> Dictionary:
	for slot in range (0, INVENTORY_MAX_SLOTS):
		if(int(data.inventory[str(slot)]["id"]) == 1):
			data.inventory[str(slot)]["amount"] = float(data.inventory[str(slot)]["amount"])
			if(data.inventory[str(slot)]["amount"] < amount):
				amount = amount - data.inventory[str(slot)]["amount"]
				data.inventory[str(slot)]["amount"] = 0.00
				data.inventory[str(slot)]["id"] = "0"
			else:
				data.inventory[str(slot)]["amount"] = data.inventory[str(slot)]["amount"] - amount
				if(data.inventory[str(slot)]["amount"] <= 0):
					data.inventory[str(slot)]["id"] = "0"
				break
				
	return data


func plus_money(amount, data) -> Dictionary:
	for slot in range (0, INVENTORY_MAX_SLOTS):
		if(int(data.inventory[str(slot)]["id"]) == 1):
			data.inventory[str(slot)]["amount"] += amount
			return data
	data = inventory_add_item(1,amount,data)
	return data


func inventory_get_empty_slot(data) -> int:
	if(data):
		for slot in range(0, INVENTORY_MAX_SLOTS):
			if (int(data.inventory[str(slot)]["id"]) == 0): 
				return int(slot)
		print ("Inventory is full!")
		get_parent().show_info("Inventory is full!")
	return -1


func is_inventory_empty_by_data(data) -> bool:
	if(data):
		for slot in range(0, INVENTORY_MAX_SLOTS):
			if (int(data.inventory[str(slot)]["id"]) != 0): 
				return false
		print ("Inventory is empty!")
	return true


func inventory_add_item(item_id:int, amount:int, data) -> Dictionary:
	var item_data:Dictionary = Global_ItemDatabase.get_item(str(item_id))
	if (item_data.empty()): 
		return Dictionary()
	if (int(item_data["stack_limit"]) <= 1):
		var slot = inventory_get_empty_slot(data)
		if (slot < 0): 
			return Dictionary()
		data.inventory[String(slot)] = {"id": String(item_id), "amount": amount}
		return data
	for slot in range (0, INVENTORY_MAX_SLOTS):
		if (int(data.inventory[String(slot)]["id"]) == int(item_id)):
			if (int(item_data["stack_limit"]) > int(data.inventory[String(slot)]["amount"])):
				data.inventory[String(slot)]["amount"] = int(data.inventory[String(slot)]["amount"] + amount)
				return data

	var slot = inventory_get_empty_slot(data)
	if (slot < 0): 
		return Dictionary()
	data.inventory[String(slot)] = {"id": String(item_id), "amount": amount}
	return data


remote func inventory_save_items(url_data, data):
	Global_DataParser.write_data(url_data, data)


func _get_item_id_from_slot_id(slot_id:int, data) -> int:
	return int(data["inventory"][str(slot_id)]["id"])


func _on_ItemList_item_selected(index):
	if(!_item_list_1.get_item_text(index) == " "):
		var item_id = _get_item_id_from_slot_id(index, data_player)
		_update_center_item(index, _item_list_1, item_id)
		set_center_item_visible(true)
		if(button_multi.text == "Buy" || button_multi.text == "Sell" ):
			button_multi.text = "Sell"
		elif(button_multi.text == "Take" && _item_list_2.visible):
			button_multi.text = "Give"
	_item_list_2.unselect_all()


func _on_ItemList2_item_selected(index):
	if(!_item_list_2.get_item_text(index) == " "):
		var item_id = _get_item_id_from_slot_id(index, data_other)
		_update_center_item(index, _item_list_2, item_id)
		set_center_item_visible(true)
		if(button_multi.text == "Buy" || button_multi.text == "Sell" ):
			button_multi.text = "Buy"
		elif(button_multi.text == "Give" && _item_list_2.visible):
			button_multi.text = "Take"
	_item_list_1.unselect_all()


func _on_HSlider_value_changed(value):
	$Panel/LineEdit.text = var2str(int(value)).replace('"', '')


func _on_Button_pressed():
	var selected_items_player = $Panel/ItemList.get_selected_items()
	var selected_items_shop = $Panel/ItemList2.get_selected_items()
	var selected_items
	
	var item_list
	var data
	
	if(!selected_items_player.empty()):
		selected_items = selected_items_player
		item_list = _item_list_1
		data = data_player
	elif(!selected_items_shop.empty()):
		selected_items = selected_items_shop
		item_list = _item_list_2
		data = data_other
	
	if(selected_items && item_list):
		var item_id = int(data.inventory[str(selected_items[0])]["id"])
		var slot_id = int(selected_items[0])
		var amount = float($Panel/LineEdit.text)
		
		if(amount > 0):
			if(_item_list_2.visible):
#				if(item_id == 1): return ## dont trade money for money lol, server resources are MY PRECIOUSSS
				if(button_multi.text == "Buy"):
					if(get_money_by_data(data_player) >= get_item_price(item_id) * amount):
						inventory_add_item(item_id,amount,data_player)
						minus_money(get_item_price(item_id) * amount, data_player)
						plus_money(get_item_price(item_id) * amount, data_other)
	#					rpc("inventory_save_items", url_data_player, data_player)
	#					rpc("inventory_save_items", url_data_other, data_other)
	#					rset('data_player', data_player)
	#					rset('data_other', data_other)
					else:
						print("Not enough money player!")
						get_parent().show_info("Not enough money player!")
						return
				elif(button_multi.text == "Sell" || button_multi.text == "Trade"):
					if(get_money_by_data(data_other) >= get_item_price(item_id) * amount):
						inventory_add_item(item_id,amount,data_other)
						minus_money(get_item_price(item_id) * amount, data_other)
						plus_money(get_item_price(item_id) * amount, data_player)
	#					rpc("inventory_save_items", url_data_player, data_player)
	#					rpc("inventory_save_items", url_data_other, data_other)
	#					rset('data_player', data_player)
	#					rset('data_other', data_other)
					else:
						print("Not enough money shop!")
						get_parent().show_info("Not enough money shop!")
						return
				elif(button_multi.text == "Take"):
					inventory_add_item(item_id,amount,data_player)
				elif(button_multi.text == "Give"):
					inventory_add_item(item_id,amount,data_other)
			elif(button_multi.text == "Drop"):
				data_other = {"inventory":{}} # create empty inventory
				for slot_id in range (0, INVENTORY_MAX_SLOTS): # fill empty inventory with placeholder
					data_other["inventory"][str(slot_id)] = {"id": "0", "amount": 0}
					
				data_other = inventory_add_item(item_id,amount,data_other) # add item to inventory
				
				get_parent().rpc_spawn_bag(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)
				
			if(data.inventory[str(slot_id)]["amount"] - amount > 0):
				data.inventory[str(slot_id)]["amount"] -= amount
			else:
				data.inventory[str(slot_id)]["id"] = 0
				data.inventory[str(slot_id)]["amount"] = 0
	
			if(!data_player.empty()):
				Global_DataParser.write_data(url_data_player, data_player)
				load_items(_item_list_1, data_player)
			if(!data_other.empty()):
				Global_DataParser.write_data(url_data_other, data_other)
				load_items(_item_list_2, data_other)
			
			set_center_item_visible(false)
			get_parent().update_vars()
