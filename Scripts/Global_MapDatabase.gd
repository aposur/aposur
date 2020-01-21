extends Node

onready var itemData:Dictionary = Global_DataParser.load_data("res://Database//database_map.json")

func get_item(id:String) -> Dictionary:
	if !itemData.has(id):
		print("Location does not exist.")
		return {}

	itemData[(id)]["id"] = (id)
	return itemData[(id)]
