extends Control

@onready var play_button: Button = $PanelContainer/MarginContainer/VBoxContainer/Play
@onready var settings_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Settings
@onready var exit_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Exit


func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)


func _on_play_button_pressed():
	Events.play.emit()


func _on_settings_button_pressed():
	GameControl.interface.hide_all_menus()
	GameControl.interface.back_menu = "main"
	GameControl.interface.show_menu_by_name("settings")


func _on_exit_button_pressed():
	Events.exit.emit()
