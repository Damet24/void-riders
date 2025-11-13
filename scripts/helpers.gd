## Helpers.gd — Conjunto de funciones utilitarias reutilizables
## Este script contiene funciones generales y matemáticas que
## pueden ser utilizadas desde cualquier parte del código.
##
## Ejemplo:
## ```
## var value = Helpers.approach(current_speed, target_speed, delta * 5)
## ```
##
## Ideal para interpolaciones, cálculos, manipulación de vectores,
## o lógica independiente del estado del juego.

extends Node

## Ajusta gradualmente un valor numérico hacia un objetivo a una velocidad dada.
##
## @param init Valor inicial o actual.
## @param target Valor objetivo al que se quiere llegar.
## @param delta Cantidad máxima que se puede mover hacia el objetivo por llamada.
##
## @return El nuevo valor aproximado hacia el objetivo.
##
## Ejemplo:
## ```
## position.x = Helpers.approach(position.x, target_x, delta * 50)
## ```
func approach(init: float, target: float, delta: float) -> float:
	if init < target:
		return min(init + delta, target)
	elif init > target:
		return max(init - delta, target)
	return target


## Formatea un valor de tiempo (en segundos) en formato mm:ss.
##
## @param seconds Tiempo total en segundos.
## @return Cadena formateada como "mm:ss"
##
## Ejemplo:
## ```
## var time_str = Helpers.format_time(75)  # "01:15"
## ```
func format_time(seconds: int) -> String:
	var minutes = int(seconds / 60.0)
	var secs = int(seconds % 60)
	return str(minutes).pad_zeros(2) + ":" + str(secs).pad_zeros(2)


## Realiza una transición suave del volumen de un `AudioStreamPlayer`.
##
## Este método interpola el volumen desde su valor actual hasta un valor final
## (por defecto -15 dB) durante el tiempo especificado.
##
## @param stream_player Nodo `AudioStreamPlayer` cuyo volumen se va a transicionar.
## @param time Duración de la transición en segundos. Valor por defecto: `1.0`
## @param final Volumen final en decibelios. Valor por defecto: `-15.0`.
func volume_transition(stream_player: AudioStreamPlayer, time: float = 1.0, final: float = -15.0) -> void:
	stream_player.create_tween().tween_property(stream_player, "volume_db", final, time)


## Crea un timer
##
## Este método creaun timer y lo configura para unsarlo en cualquier nodo
## @param time Tiempo del timer. Valor por defecto: 1.0
## @param autostart Le dice al timer si tiene que empezar automaticamente. Valor por defecto: false
## @param one_shoot Le dice al timer si se activa varias veces. Valor por defecto: false
func create_timer(callback: Callable, time: float = 1.0, autostart: bool = false, one_shoot: bool = true):
	var timer = Timer.new()
	timer.autostart = autostart
	timer.one_shot = one_shoot
	timer.wait_time = time
	timer.timeout.connect(callback)
	return timer


func get_enemy_bullet_damage(base_damage: int, wave_number: int) -> int:
	return base_damage + int((wave_number - 1) / 8.0)