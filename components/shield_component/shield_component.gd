class_name ShieldComponent
extends Node

signal shield_activated
signal shield_deactivated
signal shield_damaged(current_amount: int, damage: int)
signal shield_recharged(current_amount: int, amount: int)
signal shield_broken

@export var sprite: Sprite2D
@export var rotation_speed: float = 5.0
@export var max_hits: int = 5


var max_shield_amount = Helpers.get_enemy_bullet_damage(1, GameControl.waves.current_wave) * max_hits
var shield_active: bool = false
var shield_amount: int


func _ready() -> void:
	shield_amount = Helpers.get_enemy_bullet_damage(1, GameControl.waves.current_wave) * max_hits
	sprite.visible = false


func _process(delta: float) -> void:
	if not shield_active:
		return

	sprite.rotation += rotation_speed * delta

	var should_be_visible = shield_amount > 0
	if sprite.visible != should_be_visible:
		sprite.visible = should_be_visible


func take_damage(amount: int) -> void:
	if not shield_active:
		return

	shield_amount = max(0, shield_amount - amount)
	shield_damaged.emit(shield_amount, amount)

	if shield_amount <= 0:
		shield_broken.emit()
		deactivate()


func absorb_damage(damage: int) -> int:
	take_damage(damage)
	return 0


func recharge(amount: int = max_shield_amount) -> void:
	var prev = shield_amount
	shield_amount = min(max_shield_amount, shield_amount + amount)
	if shield_amount > prev:
		emit_signal("shield_recharged", shield_amount, amount)


func reset() -> void:
	shield_amount = max_shield_amount


func activate() -> void:
	shield_active = true
	sprite.show()
	shield_activated.emit()


func deactivate() -> void:
	shield_active = false
	sprite.hide()
	shield_deactivated.emit()
