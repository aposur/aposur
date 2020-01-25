extends Node


const IS_LOAD_FROM_FILE_ENABLED = false # true - load/save data from/to outside executable .json files, false - use only variables


var file:File

onready var rng = RandomNumberGenerator.new()


onready var data_global:Dictionary = { "res://Database//items.json":
	{	"inventory": {
			"0": {
				"name": "",
				"icon": "res://Assets/Images/Items/empty_slot.png",
				"type": "misc",
				"weight": 0.0,
				"stackable": false,
				"stack_limit": 1,
				"description": "",
				"sell_price": 0
			},
			
			"1": {
				"name": "Insects",
				"icon": "res://Assets/Images/Items/insects.png",
				"type": "food",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Use it as cash or food.",
				"sell_price": 1
			},
			
			"2": {
				"name": "AK-47",
				"icon": "res://Assets/Images/Items/ak-47.png",
				"type": "weapon",
				"damage":40,
				"need_ammo":true,
				"weight": 4,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Most sold assault rifle in the world.\nAmmo: 7.62×39mm",
				"sell_price": 40
			},
		
			"3": {
				"name": "Water bottle",
				"icon": "res://Assets/Images/Items/water-bottle.png",
				"type": "water",
				"weight": 1,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Plastic bottle full of water.\nNot the biggest one tho it is only 1l which is equal to 1kg.",
				"sell_price": 1
			},
		
			"4": {
				"name": "Jeep",
				"icon": "res://Assets/Images/Items/jeep.png",
				"type": "vehicle",
				"max_speed": 30,
				"max_weight": 70,
				"weight": 300,
				"stackable": true,
				"stack_limit": 1,
				"description": "American brand so durable that many use it as a vehicle name \"Jeep\" now.",
				"sell_price": 1000
			},
		},
	},
}


func _ready():
	if(IS_LOAD_FROM_FILE_ENABLED):
		file = File.new()


func load_data(url:String) -> Dictionary:
	if url == null: return {}
	if(IS_LOAD_FROM_FILE_ENABLED):
#		data_global = {}
		if !file.file_exists(url):
			write_data(url, data_global)
		else:
			file.open(url, File.READ)
			data_global = parse_json(file.get_as_text())
			file.close()
	return data_global.get(url, {})


func write_data(url:String, dict:Dictionary):
	if url == null: return
	
	if(IS_LOAD_FROM_FILE_ENABLED):
		var dict_save:Dictionary = {}
		dict_save[url] = dict
		file.open(url, File.WRITE)
		file.store_line(to_json(dict_save))
		file.close()
	else:
		data_global[url] = dict


func delete_file(url:String):
	if data_global.get(url) == null: return
	if(IS_LOAD_FROM_FILE_ENABLED):
		var dir = Directory.new()
		dir.remove(url)
	else:
		data_global.erase(url)
	
