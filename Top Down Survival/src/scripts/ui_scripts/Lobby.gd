extends Control

onready var name_field = $CenterContainer/VBoxContainer/Fields/NameField
onready var address_field = $CenterContainer/VBoxContainer/Fields/AddressField
onready var port_field = $CenterContainer/VBoxContainer/Fields/PortField

onready var join_button = $CenterContainer/VBoxContainer/JoinButton
onready var status_label = $CenterContainer/VBoxContainer/StatusLabel
onready var animation_player = $AnimationPlayer

func _ready():
	name_field.text = Save.save_data["player_name"]
	address_field.text = Network.DEFAULT_IP
	port_field.text = str(Network.DEFAULT_PORT)
	status_label.visible = false
	
	
func attempt_to_connect():
	animation_player.play("Connecting Animation")
	status_label.visible = true
	join_button.disabled = true
	
	Network.connect_to_server(address_field.text, int(port_field.text))
	
	
func failed_to_connect():
	animation_player.stop()
	status_label.text = "Connection Failed"
	status_label.visible = true
	join_button.disabled = false
	

func disconnected_from_server():
	status_label.text = "Disconnected From Server"
	status_label.visible = true
	join_button.disabled = false


func _on_JoinButton_pressed():
	# Cache the entered name for future use
	Save.save_data["player_name"] = name_field.text
	Save.save_game()
	
	# Make sure user has filled out a number in port field
	if port_field.text.is_valid_integer():
		attempt_to_connect()
