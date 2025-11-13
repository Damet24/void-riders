extends Enemy

func _ready():
	super._ready()
	var direction = Vector2.LEFT
	rotation = direction.angle()

	velocity = direction * speed
