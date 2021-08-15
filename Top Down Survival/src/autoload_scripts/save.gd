extends Node

const SAVEGAME = "user://savegame.json"
var save_data = {}


func _ready():
	save_data = get_data()
	
	
func get_data():
	var file = File.new()
	
	if not file.file_exists(SAVEGAME):
		save_data = {"player_name": ""}
		save_game()
		
	file.open(SAVEGAME, File.READ)
	var content = file.get_as_text()
	var data = parse_json(content)
	file.close()
	
	return data
	

func save_game():
	var file = File.new()
	file.open(SAVEGAME, File.WRITE)
	file.store_line(to_json(save_data))
