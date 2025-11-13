class_name HurtComponent
extends CharacterBody2D

@export_category("Behavior")
@export var health_component: HealthComponent
@export var sound: AudioStreamPlayer
@export var shield: ShieldComponent

func take_damage(damage: int = 1) -> void:
	if damage <= 0:
		return

	var remaining_damage = damage

	if shield != null and shield.shield_active and shield.shield_amount > 0:
		remaining_damage = shield.absorb_damage(damage)

	if remaining_damage > 0 and health_component != null:
		health_component.health -= remaining_damage

	if sound != null and (remaining_damage > 0 or shield != null):
		sound.play()
