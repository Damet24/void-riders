extends Control


func _ready() -> void:
	$MarginContainer/VBoxContainer/VBoxContainer/Value.text = str(GameControl.player_score)
	Events.player_score_changed.connect(_on_score_changed)
	Events.player_health_changed.connect(_on_plrer_health_changed)


func _on_score_changed(value: int):
	$MarginContainer/VBoxContainer/VBoxContainer/Value.text = str(value)


func _on_plrer_health_changed(value: int):
	$MarginContainer/VBoxContainer/HBoxContainer/TextureProgressBar.value = value