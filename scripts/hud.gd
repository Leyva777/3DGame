extends CanvasLayer

# Referencias a los nodos de la interfaz
@onready var score_label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var lives_label = $MarginContainer/VBoxContainer/LivesLabel

func _ready():
	update_score(0)
	update_lives(3)

func _input(event):
	# Regresar al menú con tecla M
	if event.is_action_pressed("ui_cancel") and Input.is_key_pressed(KEY_M):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

func update_score(new_score):
	"""Actualiza la etiqueta del marcador"""
	score_label.text = "Monedas: " + str(new_score)

func update_lives(lives):
	"""Actualiza el contador de vidas"""
	var hearts = ""
	for i in range(lives):
		hearts += "♥ "
	lives_label.text = "Vidas: " + hearts
