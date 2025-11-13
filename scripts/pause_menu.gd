extends Control

@onready var continue_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/Continue
@onready var settings_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/Settings
@onready var main_menu_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/MainMenu
@onready var exit_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/Exit



func _ready() -> void:
	continue_button.pressed.connect(_on_continue_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)


func _on_continue_button_pressed():
	GameControl.toggle_pause()


func _on_settings_button_pressed():
	GameControl.interface.back_menu = "pause"
	GameControl.interface.hide_all_menus()
	GameControl.interface.show_menu_by_name("settings")


func _on_main_menu_button_pressed():
	Events.finish_game.emit()


func _on_exit_button_pressed():
	Events.exit.emit()