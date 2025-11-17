extends Area3D

# Valor de la moneda
@export var coin_value = 1

# Velocidad de rotación
@export var rotation_speed = 2.0

# Señal para cuando se recoge la moneda
signal coin_collected(value)

func _ready():
	# Añadir al grupo de monedas
	add_to_group("coins")
	
	# Conectar la señal de detección de cuerpos
	body_entered.connect(_on_body_entered)

func _process(delta):
	# Rotar la moneda continuamente
	rotate_y(rotation_speed * delta)

func _on_body_entered(body):
	# Verificar si el cuerpo que entró es el jugador
	if body.is_in_group("player"):
		collect()

func collect():
	# Notificar al nodo Main
	var main = get_tree().get_first_node_in_group("main")
	if main:
		main.add_score(coin_value)
	
	# Emitir señal
	coin_collected.emit(coin_value)
	
	# Efecto de sonido (opcional)
	# $AudioStreamPlayer3D.play()
	
	# Remover la moneda
	queue_free()
