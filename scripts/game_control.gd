extends Node


var entities: EntityManager
var camera: CameraControl
var waves: Waves
var interface: InterfaceManager

var player_scene: PackedScene = load("res://objects/player/player.tscn")

var player_instance: Player = null
var playing: bool = false
var rng := RandomNumberGenerator.new()

var player_init_pos := Vector2(50, 90)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.add_property(get_instance_id(), "player_score", 0)
	Events.exit.connect(exit)
	Events.play.connect(play)
	Events.player_die.connect(_on_player_die)
	Events.finish_game.connect(finish_game)
	Events.reset.connect(_on_reset)


var player_score: int:
	get:
		return GameState.get_property(get_instance_id(), "player_score")
	set(value):
		GameState.set_property(get_instance_id(), "player_score", value)



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(Inputs.Escape) and playing:
		toggle_pause()

func toggle_pause():
	if get_tree().paused:
		get_tree().paused = false
		interface.hide_all_menus()
		interface.show_gui()
	else:
		interface.hide_all_menus()
		interface.hide_gui()
		interface.show_menu_by_name("pause")
		get_tree().paused = true


func add_player_score(value: int):
	player_score += value
	Events.player_score_changed.emit(player_score)


func play():
	interface.hide_all_menus()
	interface.show_gui()
	var player: Player = player_scene.instantiate()
	player.global_position = player_init_pos
	entities.add_entity(player)
	interface.set_player_hp(player.health_component.health)
	player_instance = player
	player_score = 0
	playing = true
	waves.reset_waves()


func exit():
	get_tree().quit()


var items = [
	{chance = 0.10, scene = load("res://objects/items/health/health.tscn"), id = "health"},
	{chance = 0.06, scene = load("res://objects/items/more_bullets/more_bullets.tscn"), id = "more_bullets"},
	{chance = 0.05, scene = load("res://objects/items/bullet_upgrade/bullet_upgrade.tscn"), id = "upgrade"},
	{chance = 0.01, scene = load("res://objects/items/power_up/power_up.tscn"), id = "power_up"},
	{chance = 0.09, scene = load("res://objects/items/shield/shield.tscn"), id = "shield"}
]

func spawn_item(_position: Vector2):
	var available = items.duplicate(true)

	if GameControl.player_instance.bullet_amount >= GameControl.player_instance.max_bullet_amount:
		available = available.filter(func(i): return i.id != "more_bullets")
	if GameControl.player_instance.bullet_amount == GameControl.player_instance.bullets.size() - 1:
		available = available.filter(func(i): return i.id != "upgrade")

	if available.is_empty():
		return

	var r = rng.randf()
	var cumulative = 0.0
	for i in available:
		cumulative += i.chance
		if r < cumulative:
			var item: Node2D = i.scene.instantiate()
			item.global_position = _position
			GameControl.entities.add_entity.call_deferred(item)
			return


func finish_game():
	waves.stop()
	player_instance.queue_free()
	playing = false
	interface.hide_gui()
	interface.show_menu_by_name("main")
	entities.remove_all()
	get_tree().paused = false


func _on_player_die():
	playing = false
	get_tree().paused = true
	interface.hide_all_menus()
	interface.show_menu_by_name("game_over")


func _on_reset():
	player_instance.global_position = player_init_pos
	interface.show_gui()
	interface.hide_all_menus()
	entities.remove_all()
	waves.reset_waves()
	player_instance.health_component.health = player_instance.health_component.max_health
	playing = true
	player_score = 0
	player_instance.reset()
	get_tree().paused = false
	Events.player_score_changed.emit(0)
