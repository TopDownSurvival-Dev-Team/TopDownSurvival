extends Control

onready var name_field = $CenterContainer/VBoxContainer/Fields/NameField
onready var address_field = $CenterContainer/VBoxContainer/Fields/AddressField
onready var port_field = $CenterContainer/VBoxContainer/Fields/PortField

func _ready():
	name_field.text = Save.save_data["player_name"]
	address_field.text = Network.DEFAULT_IP
	port_field.text = str(Network.DEFAULT_PORT)


func _on_JoinButton_pressed():
	# Cache the entered name for future use
	Save.save_data["player_name"] = name_field.text
	Save.save_game()
	
	# Make sure user has filled out a number in port field
	if port_field.text.is_valid_integer():
		Network.connect_to_server(address_field.text, int(port_field.text))
