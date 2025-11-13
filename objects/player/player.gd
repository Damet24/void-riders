class_name Player
extends CharacterBody2D


@export_category("Movement")
@export var speed: float = 200.0
@export var acceleration: float = 10.0
@export var friction: float = 10.0


@export_category("Behavior")
@export var sprite: Sprite2D
@export var health_component: HealthComponent
@export var shield_component: ShieldComponent

var active_power_up: bool = false

@export_category("Shoot settings")
var bullet_index: int = 0:
	set(value):
		print("tal: set bullet index: ", value)
		bullet_index = clamp(value, 0, bullets.size() - 1)
		print("tal: new bullet_index: ", bullet_index)

var bullets = [
	preload("res://objects/bullets/bullet_01.tscn"),
	preload("res://objects/bullets/bullet_02.tscn"),
	preload("res://objects/bullets/bullet_03.tscn"),
	preload("res://objects/bullets/bullet_04.tscn"),
	preload("res://objects/bullets/bullet_05.tscn"),
	preload("res://objects/bullets/bullet_06.tscn"),
	preload("res://objects/bullets/bullet_07.tscn"),
	preload("res://objects/bullets/bullet_08.tscn"),
	preload("res://objects/bullets/bullet_09.tscn"),
	preload("res://objects/bullets/bullet_10.tscn"),
	preload("res://objects/bullets/bullet_11.tscn"),
]

@export_enum("Spread", "Circle")
var shoot_type := 0
@export var bullet_amount: int = 1
@export var bullet_speed: float = 200.0

var can_shoot: bool = true
@export var bullet_timer: Timer
@export var shoot_sound: AudioStreamPlayer
@export var max_bullet_amount: int = 8

func _ready():
	bullet_timer.timeout.connect(_on_timer_timeout)
	health_component.health_changed.connect(_on_health_changed)
	health_component.death.connect(func(): Events.player_die.emit())
	shield_component.shield_damaged.connect(_on_shield_damaged)


func _on_shield_damaged(_current_amount: int, _damage: int):
	GameControl.camera.trigger_shake(CameraControl.SHAKE.SOFT)


func _on_health_changed(value: int):
	GameControl.camera.trigger_shake(CameraControl.SHAKE.HARD)
	Events.player_health_changed.emit(value)


func shoot():
	match shoot_type:
		0:
			var angle_step = 15.0
			var start_angle = - angle_step * (bullet_amount - 1) / 2
			for i in range(bullet_amount):
				var bullet: Bullet = bullets[bullet_index].instantiate()
				bullet.global_position = global_position
				bullet.direction = Vector2.from_angle(deg_to_rad(start_angle + angle_step * i))
				get_parent().add_child(bullet)
				bullet.attack_enemy()
		1:
			var angle_step = 360.0 / bullet_amount
			for i in range(bullet_amount):
				var bullet = bullets[bullet_index].instantiate()
				bullet.global_position = global_position
				bullet.direction = Vector2.from_angle(deg_to_rad(angle_step * i))
				get_parent().add_child(bullet)
				bullet.attack_enemy()

	can_shoot = false
	bullet_timer.start()
	shoot_sound.play()

func _process(_delta: float) -> void:
	if Input.is_action_pressed(Inputs.Shoot) and can_shoot:
		shoot()


func _physics_process(_delta: float) -> void:
	var movement = Input.get_vector(Inputs.Left, Inputs.Right, Inputs.Up, Inputs.Down)

	if movement.y < -0.3:
		sprite.frame = 0
	elif movement.y > 0.3:
		sprite.frame = 2
	else:
		sprite.frame = 1


	if movement != Vector2.ZERO:
		var vel_x = Helpers.approach(velocity.x, speed * movement.x, acceleration)
		var vel_y = Helpers.approach(velocity.y, speed * movement.y, acceleration)
		velocity = Vector2(vel_x, vel_y)
	else:
		var vel_x = Helpers.approach(velocity.x, 0.0, friction)
		var vel_y = Helpers.approach(velocity.y, 0.0, friction)
		velocity = Vector2(vel_x, vel_y)
	
	move_and_slide()

func _on_timer_timeout():
	can_shoot = true


func reset():
	bullet_amount = 1
	bullet_index = 0


func power_up():
	if active_power_up: return
	active_power_up = true
	var local_amount= bullet_amount
	var local_bullet_index = bullet_index
	shoot_type = 1
	bullet_amount = 15
	if bullet_index < bullets.size() -1:
		bullet_index += 1
	var timer: Timer = Helpers.create_timer(func():
			shoot_type = 0
			bullet_amount = local_amount
			bullet_index = local_bullet_index ,
			2.0,
			true
		)
	add_child(timer)
	await timer.timeout
	active_power_up = false
	timer.queue_free()


func activate_shield():
	shield_component.recharge()
	shield_component.activate()
