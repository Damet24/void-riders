class_name Asteroid
extends Node2D

@export var min_speed: float = 50.0
@export var max_speed: float = 200.0
@export var min_rotation_speed: float = 0.2
@export var max_rotation_speed: float = 1.0

var speed: float
var rotation_speed: float
var rotation_direction: int

func _ready() -> void:
	# Velocidad aleatoria hacia la izquierda
	speed = randf_range(min_speed, max_speed)
	
	# Velocidad de rotación aleatoria
	rotation_speed = randf_range(min_rotation_speed, max_rotation_speed)
	
	# Dirección aleatoria (1 = horario, -1 = antihorario)
	rotation_direction = randi_range(0, 1) * 2 - 1
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func _process(delta: float) -> void:
	# Movimiento hacia la izquierda
	position.x -= speed * delta
	
	# Rotación lenta y aleatoria
	rotation += rotation_direction * rotation_speed * delta
