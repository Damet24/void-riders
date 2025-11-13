## @class InterfaceManager
## @brief Gestiona todos los menús y elementos de interfaz del juego.
##
## Esta clase centraliza el control de las interfaces del juego, como el menú
## principal, el menú de pausa, los ajustes, la GUI en pantalla y las
## transiciones visuales.
##
## Su propósito es permitir mostrar, ocultar y actualizar cada elemento de la
## interfaz de manera controlada y coherente, así como reaccionar a eventos
## globales (por ejemplo, la actualización de la vida del jugador).
##
## Generalmente, se asigna una instancia global de `InterfaceManager` en
## `Game.interface_manager` durante la inicialización.
##
## @extends CanvasLayer
##
## @example
## ```gdscript
## Game.interface_manager.show_menu_by_name("pause")
## Game.interface_manager.set_player_hp(75)
## Game.interface_manager.hide_gui()
## ```
class_name InterfaceManager
extends CanvasLayer


## Referencia al nodo que contiene la interfaz del juego (HUD principal).
@onready var gui := $Gui

## Referencias a los distintos menús del juego.
@onready var main_menu := $MainMenu
@onready var settings_menu = $SettingMenu
@onready var pause_menu = $PauseMenu
@onready var game_over_menu = $GameOver

## Etiquetas de la GUI para mostrar información del jugador.
@onready var hp_label := $Gui/MarginContainer/VBoxContainer/HBoxContainer/TextureProgressBar
@onready var score_label := $Gui/MarginContainer/VBoxContainer/VBoxContainer/Value

## Lista de menús para un control centralizado.
var menus: Array[CanvasItem]


var back_menu: String = ""

## @brief Inicializa el gestor de interfaz.
##
## Asigna la instancia actual a `Game.interface_manager`, registra los menús
## en una lista, los oculta, y conecta el evento global `on_player_update_gui`
## para actualizar la vida del jugador.
func _ready() -> void:
	GameControl.interface = self
	menus = [ main_menu, settings_menu, pause_menu, game_over_menu]
	hide_all_menus()
	hide_gui()
	show_menu_by_name("main")
	Events.player_score_changed.connect(set_player_score)
	Events.player_health_changed.connect(set_player_hp)


## @brief Oculta todos los menús.
##
## Recorre la lista de menús registrados y los oculta completamente,
## excepto los que se llamen `"Transition"`.
func hide_all_menus() -> void:
	for menu in menus:
		if menu == null:
			continue
		menu.hide()
		menu.modulate.a = 0.0


## @brief Muestra solo un menú específico.
##
## Oculta todos los menús y luego muestra únicamente el que se pasa como parámetro.
## @param target_menu El menú que se desea mostrar.
##
## @example
## ```gdscript
## show_only_menu(main_menu)
## ```
func show_only_menu(target_menu: CanvasItem) -> void:
	hide_all_menus()
	await _create_fade_tween(target_menu, 1.0)


## @brief Muestra un menú por nombre.
##
## Permite seleccionar qué menú mostrar usando su nombre corto.
## Si el nombre no coincide con ninguno, muestra una advertencia.
##
## @param menu_name Nombre del menú: `"main"`, `"pause"`, `"settings"`, `"end"`.
func show_menu_by_name(menu_name: String) -> void:
	match menu_name:
		"main": await show_only_menu(main_menu)
		"pause": await show_only_menu(pause_menu)
		"settings": await show_only_menu(settings_menu)
		"game_over": await show_only_menu(game_over_menu)
		_:
			push_warning("Menu '%s' no encontrado" % menu_name)


## @brief Muestra la interfaz del juego (HUD principal).
func show_gui() -> void: await _create_fade_tween(gui, 1.0)

## @brief Oculta la interfaz del juego (HUD principal).
func hide_gui() -> void: await _create_fade_tween(gui, 0.0)


## @brief Actualiza la etiqueta de vida del jugador.
## @param value Nueva cantidad de vida.
func set_player_hp(value: int) -> void:
	var tween := create_tween()
	tween.tween_property(hp_label, "value", value, 1.0).set_trans(Tween.TRANS_ELASTIC)


## @brief Actualiza la etiqueta de puntaje del jugador.
## @param value Nuevo puntaje.

## @brief Actualiza la etiqueta de puntaje del jugador.
## @param value Nuevo puntaje.
func set_player_score(value: int) -> void:
	score_label.text = str(value)


## @brief Crea una animación de desvanecimiento (fade) en un nodo CanvasItem.
##
## Se usa para mostrar u ocultar interfaces de manera suave.
##
## @param target_node Nodo sobre el que aplicar la animación.
## @param alpha Valor de transparencia objetivo (0.0 = invisible, 1.0 = visible).
## @param duration Duración del efecto en segundos (por defecto 0.3).
func _create_fade_tween(target_node: CanvasItem, alpha: float, duration: float = 0.3) -> void:
	if alpha == 1.0:
		target_node.show()
		target_node.modulate = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_property(target_node, "modulate:a", alpha, duration)
	await tween.finished
	if alpha == 0.0:
		target_node.hide()


func back():
	if back_menu.length() > 0:
		hide_all_menus()
		show_menu_by_name(back_menu)