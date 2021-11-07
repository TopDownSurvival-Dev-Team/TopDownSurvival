extends Control

const LOGIN_SCENE = "res://src/scenes/ui_scenes/Lobby.tscn"

onready var username_field = $CenterContainer/VBoxContainer/Fields/UsernameField
onready var email_field = $CenterContainer/VBoxContainer/Fields/EmailField
onready var password_field = $CenterContainer/VBoxContainer/Fields/PasswordField

onready var register_button = $CenterContainer/VBoxContainer/RegisterButton
onready var status_label = $CenterContainer/VBoxContainer/StatusLabel
onready var animation_player = $AnimationPlayer


func _ready():
    status_label.visible = false

    # Connect signals
    Gateway.connect("gateway_connection_failure", self, "failed_to_connect_to_gateway")
    Gateway.connect("register_success", self, "registered_successfully")
    Gateway.connect("register_failure", self, "failed_to_register")


func make_fields_editable(value: bool):
    username_field.editable = value
    email_field.editable = value
    password_field.editable = value


func attempt_to_register():
    animation_player.play("Gateway Connecting Animation")
    make_fields_editable(false)
    status_label.visible = true
    register_button.disabled = true

    Gateway.register(username_field.text, email_field.text, password_field.text)


func registered_successfully():
    animation_player.stop()
    status_label.text = "Registered Successfully!"
    yield(get_tree().create_timer(5), "timeout")
    get_tree().change_scene(LOGIN_SCENE)


func failed_to_register(error_message: String):
    animation_player.stop()
    make_fields_editable(true)
    status_label.text = error_message.capitalize()
    register_button.disabled = false


func failed_to_connect_to_gateway():
    animation_player.stop()
    make_fields_editable(true)
    status_label.text = "Connection to Gateway Failed"
    register_button.disabled = false


func _on_RegisterButton_pressed():
    # Make sure user has filled out the fields
    if not username_field.text.empty() and not email_field.text.empty() and not password_field.text.empty():
        attempt_to_register()


func _on_LoginSceneButton_pressed():
    get_tree().change_scene(LOGIN_SCENE)
