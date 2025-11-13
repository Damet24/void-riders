class_name VelocityComponent
extends Node

@export var _speed: float = 100.0
@export var _acceleration: float = 5.0
@export var _friction: float = 5.0

var velocity: Vector2 = Vector2.ZERO

var speed: float:
	get:
		return _speed
	set(value):
		_speed = value


func accelerate_to_direction(x: float, y: float) -> void:
	var final_x: float = Helpers.approach(velocity.x, x * _speed, _acceleration)
	var final_y: float = Helpers.approach(velocity.y, y * _speed, _acceleration)
	velocity = Vector2(final_x, final_y)


func accelerate_to_direction_x(x: float) -> void:
	var final_x: float = Helpers.approach(velocity.x, x * _speed, _acceleration)
	velocity = Vector2(final_x, velocity.y)


func decelerate(mask: Vector2) -> void:
	var x_end: float = 0.0
	var y_end: float = 0.0
	if mask.x == 1:
		x_end = 0
	else:
		x_end = velocity.x

	if mask.y == 1:
		y_end = 0
	else:
		y_end = velocity.y

	var final_x: float = Helpers.approach(velocity.x, x_end, _friction)
	var final_y: float = Helpers.approach(velocity.y, y_end, _friction)
	velocity = Vector2(final_x, final_y)


func set_velocity(v: Vector2) -> void:
	velocity = v


func set_x_velocity(x_velocity: float) -> void:
	velocity = Vector2(x_velocity, velocity.y)


func set_y_velocity(y_velocity: float) -> void:
	velocity = Vector2(velocity.x, y_velocity)


func apply_gravity(gravity: Vector2) -> void:
	velocity += gravity


func move(body: CharacterBody2D) -> void:
	body.velocity = velocity
	body.move_and_slide()
