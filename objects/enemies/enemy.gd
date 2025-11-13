class_name Enemy
extends CharacterBody2D

@export_category("Enemy Behavior")
@export var health_component: HealthComponent
@export var explosion_scene: PackedScene
@export var score: int = 100

@export var speed: float = 200.0
var angle := 0.0


func _ready() -> void:
	health_component.death.connect(_on_death)


func _on_death():
	GameControl.camera.trigger_shake(CameraControl.SHAKE.SOFT)
	var ex = explosion_scene.instantiate() as Node2D
	ex.global_position = global_position
	get_parent().add_child(ex)
	GameControl.add_player_score(score)
	GameControl.spawn_item(global_position)
	if GameControl.waves.burrent_boss_instance == self:
		GameControl.waves.burrent_boss_instance = null
	queue_free()

func _physics_process(_delta: float) -> void:
	move_and_slide()
	
