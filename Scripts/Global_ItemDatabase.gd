extends Node

onready var itemData:Dictionary = Global_DataParser.load_data("res://Database//items.json")

func get_item(id:String) -> Dictionary:
	if !itemData.has(id):
		print("Item does not exist.")
		return {}

	itemData[(id)]["id"] = (id)
	return itemData[(id)]
