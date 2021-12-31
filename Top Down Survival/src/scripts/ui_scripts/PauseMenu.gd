extends Control

const LOBBY_SCENE_PATH = "res://src/scenes/ui_scenes/Lobby.tscn"


func _input(event):
    if event.is_action_pressed("pause"):
        toggle_visibility()


func toggle_visibility():
        if visible:
            emit_signal("focus_exited")
        else:
            emit_signal("focus_entered")

        visible = not visible


func _on_ResumeButton_pressed():
    toggle_visibility()


func _on_MenuButton_pressed():
    print("Returning to main menu...")
    Network.network.close_connection()
    var _error = get_tree().change_scene(LOBBY_SCENE_PATH)


func _on_QuitButton_pressed():
    print("Quiting...")
    get_tree().quit(0)
