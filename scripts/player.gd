extends CharacterBody3D

# Velocidad de movimiento
const SPEED = 7.0
const JUMP_VELOCITY = 15.0
const MOUSE_SENSITIVITY = 0.002
const FALL_LIMIT = -20.0  # Límite de caída al vacío

# Gravedad
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Posición inicial
var spawn_position = Vector3.ZERO

# Referencia a la cámara
@onready var camera = $CameraPivot/Camera3D
@onready var camera_pivot = $CameraPivot

func _ready():
	# Añadir al grupo de jugadores
	add_to_group("player")
	
	# Guardar posición inicial
	spawn_position = global_position
	
	# Capturar el mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Rotación de cámara con el mouse
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Rotación horizontal (Y axis)
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		# Rotación vertical (X axis)
		camera_pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		# Limitar la rotación vertical
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/2)
	
	# Liberar/capturar mouse con ESC
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Debug: Imprimir estado
	if not is_on_floor():
		print("En el aire - Posición Y: ", global_position.y, " Velocidad Y: ", velocity.y)
	
	# Verificar si cayó al vacío
	if global_position.y < FALL_LIMIT:
		respawn()
		return
	
	# Aplicar gravedad siempre (incluso si está en el suelo)
	# Solo resetear velocidad Y si está en el suelo
	if is_on_floor():
		if velocity.y < 0:
			velocity.y = 0
	else:
		velocity.y -= gravity * delta

	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Obtener dirección de entrada
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# Calcular dirección de movimiento basada en la rotación del jugador
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func respawn():
	"""Reaparecer en la posición inicial y perder una vida"""
	# Notificar al main que se perdió una vida
	var main = get_tree().get_first_node_in_group("main")
	if main:
		main.lose_life()
	
	# Reaparecer
	global_position = spawn_position
	velocity = Vector3.ZERO
	print("¡Respawn! Perdiste una vida")
