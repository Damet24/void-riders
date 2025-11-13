class_name Waves
extends Node2D

@export_category("Behavior")
@export var wave_timer: Timer
@export var wave_timer_cooldown: Timer
@export var marker: Marker2D

var asteroid_scenes = [
	load("res://objects/asteroids/asteroid_01.tscn"),
	load("res://objects/asteroids/asteroid_02.tscn")
]

var spawn_asteroids := true
var max_y: float = 136.0


var boss_interval: int = 10
var boss_health_multiplier: float = 1.0
var boss_repeat_increase: float = 1.5
var boss_spawn_count: int = 0
var bosses = [
	load("res://objects/enemies/enemy_09.tscn"),
	load("res://objects/enemies/enemy_12.tscn"),
	load("res://objects/enemies/enemy_13.tscn"),
]
var burrent_boss_instance: Enemy = null

var enemies = [
	{"level": 1, "weight": 4, "scene": load("res://objects/enemies/enemy_01/enemy_01.tscn"), "type": 0},
	{"level": 2, "weight": 3, "scene": load("res://objects/enemies/enemy_02/enemy_02.tscn"), "type": 0},
	{"level": 3, "weight": 3, "scene": load("res://objects/enemies/enemy_03.tscn"), "type": 0},
	{"level": 4, "weight": 2, "scene": load("res://objects/enemies/enemy_04.tscn"), "type": 0},
	{"level": 5, "weight": 3, "scene": load("res://objects/enemies/enemy_05.tscn"), "type": 0},
	{"level": 6, "weight": 1, "scene": load("res://objects/enemies/enemy_06.tscn"), "type": 0},
	{"level": 7, "weight": 1, "scene": load("res://objects/enemies/enemy_07.tscn"), "type": 0},
	{"level": 9, "weight": 1, "scene": load("res://objects/enemies/enemy_08.tscn"), "type": 0},
	{"level": 3, "weight": 2, "scene": load("res://objects/enemies/enemy_10/enemy_10.tscn"), "type": 1},
	{"level": 6, "weight": 2, "scene": load("res://objects/enemies/enemy_11/enemy_11.tscn"), "type": 1},
]

var current_wave: int = 1
var rng := RandomNumberGenerator.new()
var spawning := false


func pick_weighted_enemy(available: Array) -> Dictionary:
	var total = 0
	for e in available:
		total += e["weight"]
	var r = rng.randf() * total
	for e in available:
		r -= e["weight"]
		if r <= 0:
			return e
	return available.back()

func _choose_enemy_by_wave() -> Array:
	var available = enemies.filter(func(e): return e["level"] <= current_wave)
	return available


func get_spawn_position(type: int) -> Vector2:
	if type == 0:
		var point_y = randf_range(min(marker.global_position.y, max_y), max(marker.global_position.y, max_y))
		return Vector2(marker.global_position.x, point_y)
	else:
		var map_width := 320.0
		var map_height := 180.0
		var margin := 26.0

		var half_width := map_width / 2.0
		var half_height := map_height / 2.0

		# Escoge un lado al azar: 0=izq, 1=der, 2=arriba, 3=abajo
		var side := randi_range(0, 3)
		var x := 0.0
		var y := 0.0

		match side:
			0:
				x = - half_width - margin
				y = randf_range(-half_height - margin, half_height + margin)
			1:
				x = half_width + margin
				y = randf_range(-half_height - margin, half_height + margin)
			2:
				x = randf_range(-half_width - margin, half_width + margin)
				y = - half_height - margin
			3:
				x = randf_range(-half_width - margin, half_width + margin)
				y = half_height + margin

		return Vector2(x, y)


func get_spawn_point() -> float:
	var point = randf_range(min(marker.global_position.y, max_y), max(marker.global_position.y, max_y))
	return point

func spawn_enemy():
	var available_enemies = _choose_enemy_by_wave()
	if available_enemies.is_empty():
		return
	var choice = pick_weighted_enemy(available_enemies)
	var enemy: Enemy = choice["scene"].instantiate()
	enemy.global_position = get_spawn_position(choice["type"])
	GameControl.entities.add_entity(enemy)

func maybe_spawn_asteroid():
	if current_wave >= 1 and rng.randf() < 0.1:
		spawn_asteroid()

func spawn_asteroid():
	var ast_scene = asteroid_scenes[rng.randi_range(0, asteroid_scenes.size()-1)]
	var ast = ast_scene.instantiate()
	ast.global_position = Vector2(marker.global_position.x, get_spawn_point())
	GameControl.entities.add_entity(ast)


func _ready() -> void:
	GameControl.waves = self
	wave_timer.timeout.connect(_on_wave_timer_timeout)

func start():
	if spawning:
		return
	spawning = true
	wave_timer.start()
	_spawn_loop()

func stop():
	spawning = false
	wave_timer.stop()

func _on_wave_timer_timeout():
	current_wave += 1


func is_boss_wave() -> bool:
	return current_wave % boss_interval == 0


func _spawn_loop() -> void:
	if not spawning:
		return

	if get_tree().paused:
		await get_tree().process_frame
		_spawn_loop()
		return


	if is_boss_wave() and burrent_boss_instance == null:
		spawn_boss()
		await get_tree().create_timer(5.0, false, false).timeout # Pausa tras jefe
	else:
		spawn_enemy()
		maybe_spawn_asteroid()

	var wait_time = randf_range(0.2, 0.8)
	await get_tree().create_timer(wait_time, false, false).timeout

	_spawn_loop()


func reset_waves():
	spawning = false
	wave_timer.stop()
	wave_timer_cooldown.stop()

	current_wave = 1

	for child in GameControl.entities.get_children():
		if child is Enemy or child.name.begins_with("Asteroid"):
			child.queue_free()

	rng.randomize()

	await get_tree().process_frame

	spawning = true
	wave_timer.start()
	_spawn_loop()


func spawn_boss():
	var boss_index = boss_spawn_count % bosses.size()
	var boss_scene = bosses[boss_index]
	var boss = boss_scene.instantiate()
	burrent_boss_instance = boss
	boss.global_position = Vector2(marker.global_position.x, 90)

	var base_health = boss.health_component.max_health
	boss.health_component.health = base_health * boss_health_multiplier

	GameControl.entities.add_entity(boss)

	boss_spawn_count += 1

	# Cada ciclo completo de jefes aumenta la dificultad
	if boss_spawn_count % bosses.size() == 0:
		boss_health_multiplier *= boss_repeat_increase
