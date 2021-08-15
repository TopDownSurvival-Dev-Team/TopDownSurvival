extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 8000

var network = NetworkedMultiplayerENet.new()
var selected_ip: String
var selected_port: int

var local_player_id = 0
sync var players = {}
sync var player_data = {}


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	get_tree().connect("connected_to_server", self, "_connection_successful")
	get_tree().connect("connection_failed", self, "_connection_failed")
	
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func _connect_to_server():
	network.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(network)


func _player_connected(id):
	print("Player " + str(id) + " has connected")


func _player_disconnected(id):
	print("Player " + str(id) + " has disconnected")


func _connection_successful():
	print("Successfully connected to server")


func _connection_failed():
	print("Failed to connect to server")


func _server_disconnected():
	print("Disconnected from server")
