extends Node


const URL_ITEMS:String = "res://Database//items.json"


var data:Dictionary
var itemData:Dictionary


func _ready():
	data = Global_DataParser.load_data(URL_ITEMS)
	itemData = data.get("inventory", {})
#	itemData = data.get("inventory", {})
#	if(Global_DataParser.IS_LOAD_FROM_FILE_ENABLED):
#		if(!Global_DataParser.file.file_exists(URL_ITEMS)):
#			Global_DataParser.write_data(URL_ITEMS, data)


func get_item(id:String) -> Dictionary:
	if !itemData.has(id):
		print("Item does not exist.")
		return {}

	itemData[(id)]["id"] = (id)
	return itemData[(id)]
