extends Node2D
class_name BulletShooter

@export_category("Bullet Settings")
@export var bullet_scene: PackedScene
@export var bullet_speed: float = 200.0
@export var bullet_count: int = 1
@export var spread_angle: float = 0.0
@export var shoot_direction: Vector2 = Vector2.LEFT
@export_enum("Single", "Spread", "Circle", "Burst") var shoot_type: String = "Single"

@export_category("Timers")
@export var wait_timer: Timer
@export var cooldown_timer: Timer
@export var wait_time: float = 0.5
@export var cooldown_time: float = 0.2

@export_category("Optional")
@export_enum("raycast", "area") var collision_type: int
@export var raycast: RayCast2D
@export var area: Area2D
@export var shoot_sound: AudioStreamPlayer

@export var aim_to_player: bool = false

@export var ignore_cooldown: bool = false

var can_shoot: bool = true
var last_target: Object = null


func _ready() -> void:
	wait_timer.timeout.connect(_on_wait_timeout)
	if not ignore_cooldown:
		cooldown_timer.timeout.connect(_on_cooldown_timeout)


	if collision_type == 0:
		if raycast:
			raycast.enabled = true


func _process(_delta: float) -> void:
	if ignore_cooldown: return
	if collision_type == 0:
		if not raycast:
			return

		var collider = raycast.get_collider()
		if collider != null and can_shoot and collider != last_target and wait_timer.is_stopped():
			last_target = collider
			wait_timer.start(wait_time)
		elif collider == null:
			last_target = null
	elif collision_type == 1:
		if not area: return 
		if area.get_overlapping_bodies().size() > 0  and can_shoot:
			wait_timer.start(wait_time)


func _on_wait_timeout() -> void:
	_shoot()


func _shoot() -> void:
	if not bullet_scene:
		return
	if not can_shoot and not ignore_cooldown:
		return

	if not ignore_cooldown: can_shoot = false

	match shoot_type:
		"Single":
			_shoot_single()
		"Spread":
			_shoot_spread()
		"Circle":
			_shoot_circle()
		"Burst":
			_shoot_burst()

	if shoot_sound:
		shoot_sound.play()

	if not ignore_cooldown: cooldown_timer.start(cooldown_time)



func _shoot_single() -> void:
	if aim_to_player:
		print("disparando apuntando")
		var dir := (GameControl.player_instance.global_position - global_position).normalized()
		_spawn_bullet(dir)
	else:
		print("disparando sin apuntar")
		_spawn_bullet(shoot_direction)


func _shoot_spread() -> void:
	if bullet_count <= 1:
		_spawn_bullet(shoot_direction)
		return

	var total_angle = (bullet_count - 1) * spread_angle
	var start_angle = -total_angle / 2

	for i in bullet_count:
		var angle = deg_to_rad(start_angle + i * spread_angle)
		var dir = shoot_direction.rotated(angle).normalized()
		_spawn_bullet(dir)



func _shoot_circle() -> void:
	for i in bullet_count:
		var angle = TAU * i / bullet_count
		var dir = Vector2.RIGHT.rotated(angle)
		_spawn_bullet(dir)



func _shoot_burst() -> void:
	var burst_count = 3
	var delay = 0.1
	for i in burst_count:
		await get_tree().create_timer(delay * i).timeout
		_shoot_spread()



func _spawn_bullet(dir: Vector2) -> void:
	print("direction: ", dir, " bala: ", bullet_scene)
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.rotation = dir.angle()
	
	bullet.direction = dir
	bullet.speed = bullet_speed
	bullet.damage = Helpers.get_enemy_bullet_damage(1, GameControl.waves.current_wave)
	
	GameControl.entities.add_entity(bullet)

	if bullet.has_method("attack_enemy"):
		bullet.attack_player()


func _on_cooldown_timeout() -> void:
	can_shoot = true
