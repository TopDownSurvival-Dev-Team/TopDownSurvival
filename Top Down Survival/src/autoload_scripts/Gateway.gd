extends Node


enum ConnectionReason {
    LOGIN,
    REGISTER
}


signal gateway_connection_success
signal gateway_connection_failure

signal register_success
signal register_failure(error_message)
signal login_success(token)
signal login_failure(error_message)

var network: NetworkedMultiplayerENet
var gateway_api: MultiplayerAPI
const GATEWAY_ADDRESS = "gateway.topdownsurvival.tk"
const GATEWAY_PORT = 8001
var cert = load("res://assets/certificates/TopDownSurvival-Gateway-Cert.crt")
var connection_reason

var game_server_address: String
var username: String
var email: String
var password: String


func _process(_delta):
    if get_custom_multiplayer() == null:
        return
    if not custom_multiplayer.has_network_peer():
        return
    custom_multiplayer.poll()


func _connect_to_server():
    network = NetworkedMultiplayerENet.new()
    gateway_api = MultiplayerAPI.new()

    # Setup DTLS encryption
    network.set_dtls_enabled(true)
    network.set_dtls_certificate(cert)

    # Setup custom MultiplayerAPI
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
            rpc_id(1, "login_request", game_server_address, email, password)
        ConnectionReason.REGISTER:
            print("Sending register request")
            rpc_id(1, "register_request", username, email, password)

    emit_signal("gateway_connection_success")
    game_server_address = ""
    username = ""
    email = ""
    password = ""


func _connection_failed():
    print("Failed to connect to a gateway server")
    emit_signal("gateway_connection_failure")

    game_server_address = ""
    username = ""
    email = ""
    password = ""


remote func register_success():
    print("Registered successfully")
    emit_signal("register_success")


remote func register_failed(error_message: String):
    print("Register failed")
    emit_signal("register_failure", error_message)


remote func login_success(token: String):
    print("Logged in successfully")
    emit_signal("login_success", token)


remote func login_failed(error_message: String):
    print("Log in failed")
    emit_signal("login_failure", error_message)


func register(_username: String, _email: String, _password: String):
    username = _username
    email = _email
    password = _password

    connection_reason = ConnectionReason.REGISTER
    _connect_to_server()


func login(_address: String, _email: String, _password: String):
    game_server_address = _address
    email = _email
    password = _password

    connection_reason = ConnectionReason.LOGIN
    _connect_to_server()
