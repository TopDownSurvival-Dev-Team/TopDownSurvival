extends Node


enum ConnectionReason {
	LOGIN,
	REGISTER
}


var network: NetworkedMultiplayerENet
var gateway_api: MultiplayerAPI
const GATEWAY_ADDRESS = "127.0.0.1"  # will be changed when gateway is deployed to production
const GATEWAY_PORT = 8001
var connection_reason

var username: String
var email: String
var password: String


func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
	
func _connect_to_server():
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	
	network.create_client(GATEWAY_ADDRESS, GATEWAY_PORT)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_succeeded", self, "_connection_successful")
	network.connect("connection_failed", self, "_connection_failed")
	
	
func _connection_successful():
	print("Connected to a gateway server")
	
	match connection_reason:
		ConnectionReason.LOGIN:
			print("Sending login request")
			rpc_id(1, "login_request", email, password)
		ConnectionReason.REGISTER:
			print("Sending register request")
			rpc_id(1, "register_request", username, email, password)
			
	get_tree().call_group("Lobby", "connected_to_gateway")
	username = ""
	email = ""
	password = ""
	
	
func _connection_failed():
	print("Failed to connect to a gateway server")
	get_tree().call_group("Lobby", "failed_to_connect_to_gateway")
	username = ""
	email = ""
	password = ""
	
	
remote func register_success():
	# TODO
	pass
	
	
remote func register_failed(error_message: String):
	# TODO
	pass
	
	
remote func login_success(player_uid: String, username: String):
	print("Logged in successfully")
	get_tree().call_group("Lobby", "attempt_to_join_game", username)
	
	
remote func login_failed(error_message: String):
	get_tree().call_group("Lobby", "failed_to_login", error_message)
	
	
func register(_username: String, _email: String, _password: String):
	username = _username
	email = _email
	password = _password
	
	connection_reason = ConnectionReason.REGISTER
	_connect_to_server()
	
	
func login(_email: String, _password: String):
	email = _email
	password = _password
	
	connection_reason = ConnectionReason.LOGIN
	_connect_to_server()
