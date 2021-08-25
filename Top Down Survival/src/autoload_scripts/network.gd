extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 8000

var network = NetworkedMultiplayerENet.new()
var local_player_id = 0

# "sync" keyword on variables allows the server to change the variable's value
# for a network peer using "rset" function
sync var players = {}
sync var player_data = {}


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	get_tree().connect("connected_to_server", self, "_connection_successful")
	get_tree().connect("connection_failed", self, "_connection_failed")
	
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func connect_to_server(address: String, port: int):
	network.create_client(address, port)
	get_tree().set_network_peer(network)


func _player_connected(id):
	print("Player " + str(id) + " has connected")


func _player_disconnected(id):
	print("Player " + str(id) + " has disconnected")


func _connection_successful():
	print("Successfully connected to server")
	
	register_player()
	rpc_id(1, "send_player_info", player_data)
	
	# Start game
	print("Starting game")
	var world_scene = preload("res://src/scenes/game_scenes/World.tscn").instance()
	get_tree().get_root().add_child(world_scene)
	get_tree().get_root().get_node("Lobby").queue_free()


func _connection_failed():
	print("Failed to connect to server")


func _server_disconnected():
	print("Disconnected from server")
	
	
func register_player():
	# TODO: Save player data on server side
	local_player_id = get_tree().get_network_unique_id()
	player_data = Save.save_data
	players[local_player_id] = player_data
