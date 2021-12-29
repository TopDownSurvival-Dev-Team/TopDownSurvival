extends Control

const REGISTER_SCENE = "res://src/scenes/ui_scenes/Register.tscn"

onready var email_field = $CenterContainer/VBoxContainer/Fields/EmailField
onready var password_field = $CenterContainer/VBoxContainer/Fields/PasswordField
onready var address_field = $CenterContainer/VBoxContainer/Fields/AddressField
onready var port_field = $CenterContainer/VBoxContainer/Fields/PortField

onready var login_button = $CenterContainer/VBoxContainer/LoginButton
onready var status_label = $CenterContainer/VBoxContainer/StatusLabel
onready var animation_player = $AnimationPlayer

onready var version_label = $NoticeContainer/VersionLabel


func _ready():
    restore_previous_credentials()

    address_field.set_text(Network.DEFAULT_IP)
    port_field.set_text(str(Network.DEFAULT_PORT))
    version_label.set_text("v%s" % GameData.client_version)
    status_label.visible = false

    # Connect signals
    Gateway.connect("gateway_connection_success", self, "connected_to_gateway")
    Gateway.connect("gateway_connection_failure", self, "failed_to_connect_to_gateway")
    Gateway.connect("login_success", self, "attempt_to_join_game")
    Gateway.connect("login_failure", self, "failed_to_login")
    Network.connect("server_connection_failed", self, "failed_to_connect_to_game")
    Network.connect("invalid_token_supplied", self, "invalid_token")
    GodotcordActivityManager.connect("activity_join", self, "accept_join_invite")

    RPCManager.set_activity_lobby()


func restore_previous_credentials():
    var credentials = CredentialsManager.get_credentials()
    email_field.set_text(credentials["email"])
    password_field.set_text(credentials["password"])


func make_fields_editable(value: bool):
    email_field.editable = value
    password_field.editable = value
    address_field.editable = value
    port_field.editable = value


func attempt_to_login():
    animation_player.play("Gateway Connecting Animation")
    make_fields_editable(false)
    status_label.visible = true
    login_button.disabled = true

    Gateway.login(address_field.text, email_field.text, password_field.text)


func attempt_to_join_game(token: String):
    animation_player.play("Game Connecting Animation")
    CredentialsManager.save_credentials(email_field.text, password_field.text)
    Network.connect_to_server(address_field.text, int(port_field.text), token)


func accept_join_invite(join_secret: String):
    var secret_split = join_secret.split(":", true, 2)
    var version = secret_split[2]

    if version == GameData.client_version:
        restore_previous_credentials()
        address_field.set_text(secret_split[0])
        port_field.set_text(secret_split[1])
        attempt_to_login()

    else:
        # TODO: Show a pop up
        print_debug("Tried to join a game with different version.\nCurrent version: %s, Requested version: %s" % [GameData.client_version, version])


func connected_to_gateway():
    animation_player.play("Authenticating Animation")


func failed_to_connect_to_gateway():
    animation_player.stop()
    make_fields_editable(true)
    status_label.text = "Connection to Gateway Failed"
    login_button.disabled = false


func failed_to_connect_to_game():
    animation_player.stop()
    make_fields_editable(true)
    status_label.text = "Connection to Game Server Failed"
    login_button.disabled = false


func failed_to_login(error_message: String):
    animation_player.stop()
    make_fields_editable(true)
    status_label.text = error_message.capitalize()
    login_button.disabled = false


func disconnected_from_server():
    status_label.text = "Disconnected From Server"
    status_label.visible = true
    login_button.disabled = false


func invalid_token():
    animation_player.stop()
    make_fields_editable(true)
    status_label.text = "Unable to Verify Auth Token"
    status_label.visible = true
    login_button.disabled = false


func _on_LoginButton_pressed():
    # Make sure user has filled out the fields correctly
    if not address_field.text.empty() and port_field.text.is_valid_integer():
        attempt_to_login()


func _on_RegisterSceneButton_pressed():
    var _error = get_tree().change_scene(REGISTER_SCENE)
