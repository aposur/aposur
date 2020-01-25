extends Node2D


onready var url_data:String = ""
onready var data:Dictionary = Dictionary()


func _ready():
	set_process(false)
	set_process_input(false)


sync func init(inventory:Control, name:String, data:Dictionary, spawn_position:Vector2):
#	inventory.load_data(inventory, name, "Bag", data)
#	rpc("load_data", inventory, name, "Bag", data)
	data = inventory.load_data(name, "Bag")
	print(data)
	position = spawn_position


#func load_data(inventory:Control, filename:String, item_list_label:String = "Bag", data_player:Dictionary = Dictionary()) -> Dictionary:
##	if(item_list_label == "Bag"):
#	url_data = "res://Database//data_bag_" + filename + ".json"
#	data = Global_DataParser.load_data(url_data)
#	if ((data.empty() && item_list_label == "Bag" && !data_player.empty())):
#		Global_DataParser.write_data(url_data, data_player)
#		data = data_player
#	return data


func reload_data() -> Dictionary:
	data = Global_DataParser.load_data(url_data)
	return data


func is_data_empty_by_inventory(inventory:Control) -> bool:
	return inventory.is_inventory_empty_by_data(data)


func rpc_destroy_self():
	rpc("destroy_self")


sync func destroy_self() -> void:
	for child in get_children():
		if child.has_method('queue_free'):
			child.queue_free()
	Global_DataParser.delete_file(url_data)
