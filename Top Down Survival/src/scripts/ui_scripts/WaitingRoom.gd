extends Popup

onready var player_list = $CenterContainer/VBoxContainer/ItemList
onready var ready_button = $CenterContainer/VBoxContainer/ReadyButton


func _ready():
	player_list.clear()
	
	
func refresh_players(players):
	player_list.clear()
	
	for player_id in players:
		var player = players[player_id]["player_name"]
		player_list.add_item(player, null, false)
		

func show_popup():
	popup_centered()


func _on_ReadyButton_pressed():
	Network.ready_up()
	ready_button.disabled = true
