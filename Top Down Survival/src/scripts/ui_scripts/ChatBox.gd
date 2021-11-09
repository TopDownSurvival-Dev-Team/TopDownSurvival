extends Control

onready var chat_log = $VBoxContainer/RichTextLabel
onready var input_field = $VBoxContainer/InputContainer/LineEdit


func _input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_ENTER:
            input_field.grab_focus()

        if event.pressed and event.scancode == KEY_ESCAPE:
            input_field.release_focus()


func send_message():
    var message_text = input_field.text.strip_edges()

    if not message_text.empty():
        print("Sending chat message: " + message_text)

        rpc_id(1, "send_message_s", message_text)
#		add_message(message_text, "Player", "FFFFFF")

        input_field.text = ""
        input_field.release_focus()


remote func add_message(message, sender, color):
    var text = "\n[color=#" + color + "]" + "[" + sender + "] " + message + "[/color]"
    chat_log.bbcode_text += text


func _on_LineEdit_text_entered(_new_text):
    send_message()


func _on_SendButton_pressed():
    send_message()


func _on_LineEdit_focus_entered():
    emit_signal("focus_entered")


func _on_LineEdit_focus_exited():
    emit_signal("focus_exited")
