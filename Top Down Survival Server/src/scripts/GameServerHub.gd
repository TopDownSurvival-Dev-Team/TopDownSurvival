extends Node

var network = NetworkedMultiplayerENet.new()
var game_server_api = MultiplayerAPI.new()
const HUB_ADDRESS = "127.0.0.1"  # Same as gateway address, will change when gateway is deployed
const HUB_PORT = 8002

var pending_tokens = {}
var used_tokens = {}


func _ready():
	network.connect("connection_succeeded", self, "_connection_successful")
	network.connect("connection_failed", self, "_connection_failed")
	
	_connect_to_hub()


func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
	
func _connect_to_hub():
	network.create_client(HUB_ADDRESS, HUB_PORT)
	set_custom_multiplayer(game_server_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	
func _connection_successful():
	print("Successfully connected to Game Server Hub")
	
	
func _connection_failed():
	print("Unable to connect to Game Server Hub, exiting...")
	get_tree().quit()
	
	
func verify_token(token: String) -> bool:
	if not token in pending_tokens:
		return false
		
	# TODO: token time limit
	
	# Invalidate the token if it's valid
	used_tokens[token] = pending_tokens[token]
	pending_tokens.erase(token)
	
	return true
	
	
func get_user_info(token: String) -> Dictionary:
	return used_tokens[token]
	
	
remote func receive_verification_info(token: String, player_info: Dictionary):
	# Contains stuff like Firebase UID and player username
	pending_tokens[token] = player_info
	print("Received token: %s" % token)
