class_name Bullet
extends Area2D


@export_category("Movement")
@export var speed: float = 500.0
var direction: Vector2 = Vector2.RIGHT

@export_category("Behavior")
@export var notificator: VisibleOnScreenNotifier2D
@export var damage: int = 1

func attack_player():
	set_collision_layer_value(5, true)
	set_collision_mask_value(2, true)
	

func attack_enemy():
	set_collision_layer_value(4, true)
	set_collision_mask_value(3, true)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	notificator.screen_exited.connect(func(): queue_free())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += direction * speed * delta
	rotation = direction.angle()


func _on_body_entered(body: Node2D):
	if body is HurtComponent:
		body.take_damage(damage)
	queue_free()
