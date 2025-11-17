extends Control

func _ready():
	# Asegurarse de que el mouse esté visible en el menú
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_play_button_pressed():
	# Cargar la escena principal del juego
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
	# Salir del juego
	get_tree().quit()
