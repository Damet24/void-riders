extends Enemy

@export var amplitude: float = 50.0
@export var frequency: float = 2.0

var base_y: float
var time_passed: float = 0.0

func _ready() -> void:
	base_y = global_position.y
	super._ready()

func _physics_process(delta: float) -> void:
	time_passed += delta
	var move_x = -speed
	var move_y = sin(time_passed * frequency * TAU) * amplitude
	velocity = Vector2(move_x, move_y)
	rotation = velocity.angle()
	move_and_slide()