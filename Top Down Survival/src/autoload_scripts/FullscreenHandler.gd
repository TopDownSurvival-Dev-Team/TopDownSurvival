extends Node


func _input(event):
    if event.is_action_pressed("toggle_fullscreen"):
        OS.window_fullscreen = not OS.window_fullscreen
