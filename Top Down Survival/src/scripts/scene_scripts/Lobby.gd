extends Control


func _on_JoinButton_pressed():
	NetworkClient._connect_to_server()
