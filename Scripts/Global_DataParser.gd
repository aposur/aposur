extends Node


onready var file = File.new()
onready var rng = RandomNumberGenerator.new()


sync func load_data(url) -> Dictionary:
	if url == null: return {}
	if !file.file_exists(url): return {}
	file.open(url, File.READ)
	var data:Dictionary = {}
	data = parse_json(file.get_as_text())
	file.close()
	return data


sync func write_data(url:String, dict:Dictionary):
	if url == null: return
	file.open(url, File.WRITE)
	file.store_line(Global_Json_Beautifier.beautify_json(to_json(dict)))
	file.close()


sync func delete_file(url:String):
	if url == null: return
	var dir = Directory.new()
	dir.remove(url)
