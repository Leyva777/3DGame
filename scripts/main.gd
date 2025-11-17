extends Node3D

# Variables del juego
var score = 0
var coins_total = 0
var lives = 3
var max_lives = 3

# Referencias
@onready var hud = $HUD

func _ready():
	# Añadir al grupo main
	add_to_group("main")
	
	# Inicializar el juego
	coins_total = get_tree().get_nodes_in_group("coins").size()
	print("Juego iniciado - Monedas totales: ", coins_total)
	
	# Actualizar HUD con vidas iniciales
	if hud:
		hud.update_lives(lives)

func add_score(points):
	"""Añade puntos al marcador"""
	score += points
	if hud:
		hud.update_score(score)
	print("Puntuación: ", score)
	
	# Verificar si se recolectaron todas las monedas
	if score >= coins_total:
		game_complete()

func lose_life():
	"""Pierde una vida"""
	lives -= 1
	if hud:
		hud.update_lives(lives)
	
	print("Vidas restantes: ", lives)
	
	# Verificar si se acabaron las vidas
	if lives <= 0:
		game_over()

func game_over():
	"""Se ejecuta cuando se pierden todas las vidas"""
	print("¡Game Over!")
	# Esperar un momento antes de mostrar pantalla de game over
	await get_tree().create_timer(1.0).timeout
	show_game_over_screen()

func show_game_over_screen():
	"""Mostrar pantalla de Game Over"""
	# Pausar el juego
	get_tree().paused = true
	
	# Crear y mostrar mensaje de game over
	var gameover_label = Label.new()
	gameover_label.text = "GAME OVER\n\nTe quedaste sin vidas\n\nPresiona ENTER para volver al menú"
	gameover_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gameover_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	gameover_label.add_theme_font_size_override("font_size", 48)
	gameover_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	gameover_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	gameover_label.add_theme_constant_override("shadow_offset_x", 3)
	gameover_label.add_theme_constant_override("shadow_offset_y", 3)
	gameover_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Fondo semi-transparente
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Añadir a HUD
	hud.add_child(bg)
	hud.add_child(gameover_label)
	
	# Esperar input para volver al menú
	await get_tree().create_timer(0.5).timeout
	while not Input.is_action_just_pressed("ui_accept"):
		await get_tree().process_frame
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func game_complete():
	"""Se ejecuta cuando se recolectan todas las monedas"""
	print("¡Felicidades! Has recolectado todas las monedas")
	# Esperar un momento antes de mostrar pantalla de victoria
	await get_tree().create_timer(1.0).timeout
	show_victory_screen()

func show_victory_screen():
	"""Mostrar pantalla de victoria"""
	# Pausar el juego
	get_tree().paused = true
	# Crear y mostrar mensaje de victoria
	var victory_label = Label.new()
	victory_label.text = "¡VICTORIA!\n\n¡Recolectaste todas las monedas!\n\nPresiona ENTER para volver al menú"
	victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victory_label.add_theme_font_size_override("font_size", 48)
	victory_label.add_theme_color_override("font_color", Color(1, 0.843, 0))
	victory_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	victory_label.add_theme_constant_override("shadow_offset_x", 3)
	victory_label.add_theme_constant_override("shadow_offset_y", 3)
	victory_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Fondo semi-transparente
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Añadir a HUD
	hud.add_child(bg)
	hud.add_child(victory_label)
	
	# Esperar input para volver al menú
	await get_tree().create_timer(0.5).timeout
	while not Input.is_action_just_pressed("ui_accept"):
		await get_tree().process_frame
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
