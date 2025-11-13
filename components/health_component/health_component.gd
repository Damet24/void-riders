class_name HealthComponent
extends Node

signal health_changed(remaining_health: int)
signal death

@export var max_health: int = 1
var _health: int = 0

var health: int:
	get:
		return _health
	set(value):
		_health = clamp(value, 0, max_health)
		health_changed.emit(_health)
		if _health <= 0:
			death.emit()

func _ready() -> void:
	_health = max_health  # ← se inicializa correctamente

func take_damage(amount: int = 1) -> void:
	health -= amount
