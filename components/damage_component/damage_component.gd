extends Area2D

func _ready() -> void:
	body_entered.connect(_on_area_entered)


func _on_area_entered(body: Node2D):
	if body.has_method("take_damage"):
		body.take_damage(Helpers.get_enemy_bullet_damage(1, GameControl.waves.current_wave))