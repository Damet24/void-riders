extends Control


@onready var play_again_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PlayAgain
@onready var settings_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MainMenu
@onready var exit_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Exit


func _ready() -> void:
	play_again_button.pressed.connect(_on_play_again_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)


func _on_play_again_button_pressed():
	Events.reset.emit()


func _on_settings_button_pressed():
	Events.finish_game.emit()


func _on_exit_button_pressed():
	Events.exit.emit()