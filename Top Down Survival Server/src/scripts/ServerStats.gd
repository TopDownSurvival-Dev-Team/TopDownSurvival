extends Control

const VERSION_FILE = "res://version.txt"

onready var version_label = $NoticeContainer/VersionLabel


func _ready():
    var f = File.new()
    f.open(VERSION_FILE, File.READ)
    var version_number = f.get_line()
    f.close()
    version_label.set_text("v%s" % version_number)
