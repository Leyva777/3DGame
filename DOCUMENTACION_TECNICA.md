# DOCUMENTACIÓN TÉCNICA: PLATFORM GAME 3D
## Practica 03 - Juego de Plataformas 3D con Colección de Monedas

---

**Autor:** Carlos Fabian Leyva Gómez - 218522926 
**Fecha:** Noviembre 2025  
**Motor:** Godot Engine 4.5  
**Lenguaje:** GDScript  
**Renderizador:** Forward+

---

## ÍNDICE

1. [Introducción](#introducción)
2. [Arquitectura del Proyecto](#arquitectura-del-proyecto)
3. [Explicación del Código Relevante](#explicación-del-código-relevante)
4. [Problemas Encontrados y Soluciones](#problemas-encontrados-y-soluciones)
5. [Conclusiones](#conclusiones)

---

## 1. INTRODUCCIÓN

### 1.1 Descripción del Proyecto

Platform Game 3D es un juego de plataformas tridimensional desarrollado en Godot 4.5 que implementa mecánicas de movimiento, recolección de objetos, sistema de vidas y gestión de escenas. El jugador debe recolectar monedas distribuidas en plataformas flotantes mientras evita caer al vacío.

### 1.2 Objetivos del Proyecto

- Implementar movimiento de personaje 3D con física realista
- Crear sistema de cámara en tercera persona con control de mouse
- Desarrollar mecánicas de recolección de objetos
- Implementar sistema de vidas y Game Over
- Gestionar transiciones entre menú y juego
- Utilizar modelos 3D externos (KayKit Assets)

### 1.3 Tecnologías Utilizadas

- **Motor:** Godot Engine 4.5
- **Lenguaje:** GDScript (similar a Python)
- **Modelos 3D:** KayKit Prototype Bits (formato GLTF)
- **Renderizador:** Forward+ (optimizado para 3D)
- **Sistema de Físicas:** Godot Physics 3D

---

## 2. ARQUITECTURA DEL PROYECTO

### 2.1 Estructura de Directorios

```
PlatformGame3D/
├── scenes/
│   ├── player/
│   │   └── player.tscn           # Escena del personaje
│   ├── items/
│   │   └── coin.tscn             # Escena de moneda recolectable
│   ├── main.tscn                 # Escena principal del juego
│   ├── menu.tscn                 # Menú principal
│   └── hud.tscn                  # Interfaz de usuario
├── scripts/
│   ├── player.gd                 # Lógica del jugador
│   ├── coin.gd                   # Lógica de monedas
│   ├── main.gd                   # Gestión del juego
│   ├── menu.gd                   # Lógica del menú
│   └── hud.gd                    # Actualización de interfaz
├── models/                       # Modelos 3D adicionales
├── materials/                    # Materiales personalizados
├── KayKit_Prototype_Bits_1.1_FREE/
│   └── Assets/gltf/              # Modelos 3D externos
└── project.godot                 # Configuración del proyecto
```

### 2.2 Diagrama de Jerarquía de Escenas

```
Main (Node3D)
├── WorldEnvironment              # Iluminación y ambiente
├── DirectionalLight3D            # Luz principal
├── FloorTiles (Node3D)
│   ├── Floor1 (StaticBody3D)     # Baldosas individuales
│   │   ├── FloorModel
│   │   └── CollisionShape3D
│   └── Floor2-9...
├── Platform1-3 (StaticBody3D)    # Plataformas flotantes
│   ├── PlatformModel
│   └── CollisionShape3D
├── Player (CharacterBody3D)
│   ├── PlayerModel
│   ├── CollisionShape3D
│   └── CameraPivot
│       └── Camera3D
├── Coin1-5 (Area3D)              # Monedas recolectables
│   ├── CoinModel
│   └── CollisionShape3D
├── Decoration (Node3D)           # Objetos decorativos
└── HUD (CanvasLayer)             # Interfaz de usuario
```

### 2.3 Sistema de Capas de Colisión

| Capa | Tipo | Descripción |
|------|------|-------------|
| 1 | StaticBody3D | Plataformas y suelos |
| 2 | CharacterBody3D | Jugador |
| 4 | Area3D | Items recolectables |

**Configuración:**
- Jugador (Capa 2) detecta Capa 1 (camina sobre plataformas)
- Monedas (Capa 4) detectan Capa 2 (recolección por contacto)

---

## 3. EXPLICACIÓN DEL CÓDIGO RELEVANTE

### 3.1 Sistema de Movimiento del Jugador (player.gd)

#### 3.1.1 Variables Principales

```gdscript
extends CharacterBody3D

# Constantes de movimiento
const SPEED = 7.0                    # Velocidad de movimiento horizontal
const JUMP_VELOCITY = 15.0           # Fuerza del salto
const MOUSE_SENSITIVITY = 0.002      # Sensibilidad de rotación de cámara
const FALL_LIMIT = -20.0             # Límite de caída al vacío

# Variables de estado
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var spawn_position = Vector3.ZERO    # Posición inicial para respawn
```

**Explicación:**
- `SPEED`: Controla qué tan rápido se mueve el personaje en unidades/segundo
- `JUMP_VELOCITY`: Determina la altura del salto (mayor valor = salto más alto)
- `MOUSE_SENSITIVITY`: Controla la velocidad de rotación de la cámara
- `FALL_LIMIT`: Define en qué punto Y el jugador ha caído al vacío
- `gravity`: Obtiene la gravedad configurada en el proyecto (20.0 unidades/s²)

#### 3.1.2 Inicialización

```gdscript
func _ready():
    add_to_group("player")
    spawn_position = global_position
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
```

**Explicación:**
- `add_to_group("player")`: Agrega el nodo al grupo "player" para identificación
- `spawn_position = global_position`: Guarda la posición inicial
- `Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)`: Captura el cursor del mouse

#### 3.1.3 Control de Cámara con Mouse

```gdscript
func _input(event):
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        # Rotación horizontal (eje Y)
        rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
        
        # Rotación vertical (eje X)
        camera_pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
        
        # Limitar rotación vertical para evitar inversión
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/2)
```

**Explicación:**
- `event.relative`: Vector de movimiento del mouse desde el último frame
- `rotate_y()`: Rota el personaje horizontalmente (mirar izquierda/derecha)
- `camera_pivot.rotate_x()`: Rota la cámara verticalmente (mirar arriba/abajo)
- `clamp()`: Limita la rotación vertical entre -90° y +90° para evitar que la cámara se invierta

**Matemática detrás del control:**
```
Ángulo nuevo = Ángulo anterior + (Movimiento del mouse × Sensibilidad)
Rotación Y = -event.relative.x × 0.002  (negativo para invertir dirección)
Rotación X limitada = clamp(ángulo, -π/2, π/2)
```

#### 3.1.4 Física del Movimiento

```gdscript
func _physics_process(delta):
    # Debug: información en consola
    if not is_on_floor():
        print("En el aire - Posición Y: ", global_position.y, 
              " Velocidad Y: ", velocity.y)
    
    # Verificar caída al vacío
    if global_position.y < FALL_LIMIT:
        respawn()
        return
    
    # Aplicar gravedad
    if is_on_floor():
        if velocity.y < 0:
            velocity.y = 0
    else:
        velocity.y -= gravity * delta
    
    # Salto
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY
```

**Explicación detallada:**

1. **Sistema de Gravedad:**
   - Si está en el suelo: velocidad Y se resetea a 0
   - Si está en el aire: se aplica aceleración gravitacional
   - Fórmula: `velocidad_y(t) = velocidad_y(t-1) - gravedad × delta_tiempo`

2. **Detección de Suelo:**
   - `is_on_floor()`: Función de Godot que detecta colisión hacia abajo
   - Utiliza ray casting interno para verificar contacto

3. **Sistema de Salto:**
   - Solo permite saltar si está tocando el suelo
   - `Input.is_action_just_pressed("jump")`: Detecta presión única (no mantener)
   - Aplica velocidad vertical instantánea hacia arriba

#### 3.1.5 Control de Movimiento Horizontal

```gdscript
# Obtener dirección de entrada
var input_dir = Input.get_vector("move_left", "move_right", 
                                 "move_forward", "move_back")

# Calcular dirección de movimiento basada en rotación del jugador
var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

if direction:
    velocity.x = direction.x * SPEED
    velocity.z = direction.z * SPEED
else:
    velocity.x = move_toward(velocity.x, 0, SPEED)
    velocity.z = move_toward(velocity.z, 0, SPEED)

move_and_slide()
```

**Explicación matemática:**

1. **Obtención de Input:**
   - `Input.get_vector()`: Retorna Vector2 normalizado de entrada
   - Valores: (-1 a 1, -1 a 1)
   - Automáticamente maneja entrada analógica y digital

2. **Transformación de Coordenadas:**
   ```
   Espacio Local → Espacio Mundial
   Vector3(input_dir.x, 0, input_dir.y) × transform.basis
   ```
   - `transform.basis`: Matriz 3x3 de rotación del personaje
   - Convierte dirección de input a dirección mundial considerando rotación

3. **Aplicación de Velocidad:**
   - Si hay input: aplica velocidad en dirección calculada
   - Si no hay input: desacelera gradualmente con `move_toward()`
   - `move_and_slide()`: Función de Godot que aplica velocidad y maneja colisiones

#### 3.1.6 Sistema de Respawn

```gdscript
func respawn():
    var main = get_tree().get_first_node_in_group("main")
    if main:
        main.lose_life()
    
    global_position = spawn_position
    velocity = Vector3.ZERO
    print("¡Respawn! Perdiste una vida")
```

**Explicación:**
- Notifica al nodo principal sobre pérdida de vida
- Resetea posición a la guardada en `_ready()`
- Resetea velocidad para evitar caída inmediata tras respawn

---

### 3.2 Sistema de Recolección de Monedas (coin.gd)

#### 3.2.1 Estructura Básica

```gdscript
extends Area3D

@export var coin_value = 1           # Valor de la moneda (configurable)
@export var rotation_speed = 2.0     # Velocidad de rotación visual

signal coin_collected(value)         # Señal emitida al recolectar
```

**Explicación:**
- `@export`: Hace variable editable en el Inspector de Godot
- `signal`: Declara evento que otros nodos pueden escuchar
- `Area3D`: Nodo que detecta overlaps sin física

#### 3.2.2 Inicialización y Rotación

```gdscript
func _ready():
    add_to_group("coins")
    body_entered.connect(_on_body_entered)

func _process(delta):
    rotate_y(rotation_speed * delta)
```

**Explicación:**
- `add_to_group("coins")`: Permite contar total de monedas
- `body_entered.connect()`: Conecta señal de colisión a función
- `rotate_y()`: Rotación continua para efecto visual
- `delta`: Tiempo transcurrido desde último frame (independiente de FPS)

#### 3.2.3 Detección y Recolección

```gdscript
func _on_body_entered(body):
    if body.is_in_group("player"):
        collect()

func collect():
    var main = get_tree().get_first_node_in_group("main")
    if main:
        main.add_score(coin_value)
    
    coin_collected.emit(coin_value)
    queue_free()
```

**Explicación del flujo:**
1. `body_entered` se dispara cuando algo entra en el Area3D
2. Verifica que sea el jugador usando grupos
3. Llama a `collect()` que:
   - Obtiene referencia al nodo principal
   - Añade puntos al marcador
   - Emite señal (para efectos de sonido, etc.)
   - `queue_free()`: Elimina el nodo al final del frame actual

---

### 3.3 Gestión del Juego Principal (main.gd)

#### 3.3.1 Variables de Estado

```gdscript
extends Node3D

var score = 0                # Puntuación actual
var coins_total = 0          # Total de monedas en el nivel
var lives = 3                # Vidas actuales
var max_lives = 3            # Vidas máximas

@onready var hud = $HUD      # Referencia al HUD
```

**Explicación:**
- `@onready`: Obtiene referencia cuando el nodo está listo
- Variables de juego centralizadas para fácil acceso

#### 3.3.2 Inicialización del Nivel

```gdscript
func _ready():
    add_to_group("main")
    coins_total = get_tree().get_nodes_in_group("coins").size()
    print("Juego iniciado - Monedas totales: ", coins_total)
    
    if hud:
        hud.update_lives(lives)
```

**Explicación:**
- `get_tree().get_nodes_in_group("coins")`: Obtiene array de todas las monedas
- `.size()`: Cuenta total de monedas para condición de victoria
- Inicializa HUD con valores iniciales

#### 3.3.3 Sistema de Puntuación

```gdscript
func add_score(points):
    score += points
    if hud:
        hud.update_score(score)
    print("Puntuación: ", score)
    
    if score >= coins_total:
        game_complete()
```

**Explicación:**
- Incrementa puntuación
- Actualiza HUD inmediatamente
- Verifica condición de victoria

#### 3.3.4 Sistema de Vidas

```gdscript
func lose_life():
    lives -= 1
    if hud:
        hud.update_lives(lives)
    
    print("Vidas restantes: ", lives)
    
    if lives <= 0:
        game_over()
```

**Explicación:**
- Decrementa contador de vidas
- Actualiza visualización en HUD
- Verifica condición de derrota

#### 3.3.5 Pantalla de Game Over

```gdscript
func game_over():
    print("¡Game Over!")
    await get_tree().create_timer(1.0).timeout
    show_game_over_screen()

func show_game_over_screen():
    get_tree().paused = true
    
    # Crear mensaje
    var gameover_label = Label.new()
    gameover_label.text = "GAME OVER\\n\\nTe quedaste sin vidas\\n\\nPresiona ENTER para volver al menú"
    gameover_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    gameover_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    gameover_label.add_theme_font_size_override("font_size", 48)
    gameover_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
    gameover_label.set_anchors_preset(Control.PRESET_FULL_RECT)
    
    # Crear fondo
    var bg = ColorRect.new()
    bg.color = Color(0, 0, 0, 0.8)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    
    # Añadir a HUD
    hud.add_child(bg)
    hud.add_child(gameover_label)
    
    # Esperar input
    await get_tree().create_timer(0.5).timeout
    while not Input.is_action_just_pressed("ui_accept"):
        await get_tree().process_frame
    
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/menu.tscn")
```

**Explicación detallada:**

1. **await get_tree().create_timer(1.0).timeout:**
   - Pausa ejecución de la función por 1 segundo
   - No bloquea el resto del juego
   - Coroutine de GDScript

2. **get_tree().paused = true:**
   - Pausa todos los nodos que no tienen `process_mode` especial
   - Detiene física y procesamiento

3. **Creación dinámica de UI:**
   - Crea Label programáticamente
   - Configura propiedades de texto y color
   - `PRESET_FULL_RECT`: Ocupa toda la pantalla

4. **Loop de espera:**
   ```gdscript
   while not Input.is_action_just_pressed("ui_accept"):
       await get_tree().process_frame
   ```
   - Espera activamente sin bloquear
   - Verifica cada frame si se presionó ENTER

5. **Transición de escena:**
   - Despausa el juego
   - Cambia a escena del menú

#### 3.3.6 Pantalla de Victoria

```gdscript
func game_complete():
    print("¡Felicidades! Has recolectado todas las monedas")
    await get_tree().create_timer(1.0).timeout
    show_victory_screen()

func show_victory_screen():
    get_tree().paused = true
    
    var victory_label = Label.new()
    victory_label.text = "¡VICTORIA!\\n\\n¡Recolectaste todas las monedas!\\n\\nPresiona ENTER para volver al menú"
    victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    victory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    victory_label.add_theme_font_size_override("font_size", 48)
    victory_label.add_theme_color_override("font_color", Color(1, 0.843, 0))
    victory_label.set_anchors_preset(Control.PRESET_FULL_RECT)
    
    var bg = ColorRect.new()
    bg.color = Color(0, 0, 0, 0.7)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    
    hud.add_child(bg)
    hud.add_child(victory_label)
    
    await get_tree().create_timer(0.5).timeout
    while not Input.is_action_just_pressed("ui_accept"):
        await get_tree().process_frame
    
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/menu.tscn")
```

**Explicación:**
- Similar a Game Over pero con colores y mensaje diferentes
- Color dorado (1, 0.843, 0) para victoria
- Fondo menos oscuro (0.7 alpha vs 0.8)

---

### 3.4 Sistema de Menú (menu.gd)

```gdscript
extends Control

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_play_button_pressed():
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
    get_tree().quit()
```

**Explicación:**
- Control simple de navegación
- `change_scene_to_file()`: Descarga escena actual y carga nueva
- `quit()`: Cierra aplicación correctamente

---

### 3.5 Interfaz de Usuario (hud.gd)

```gdscript
extends CanvasLayer

@onready var score_label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var lives_label = $MarginContainer/VBoxContainer/LivesLabel

func _ready():
    update_score(0)
    update_lives(3)

func _input(event):
    if event.is_action_pressed("ui_cancel") and Input.is_key_pressed(KEY_M):
        get_tree().change_scene_to_file("res://scenes/menu.tscn")

func update_score(new_score):
    score_label.text = "Monedas: " + str(new_score)

func update_lives(lives):
    var hearts = ""
    for i in range(lives):
        hearts += "♥ "
    lives_label.text = "Vidas: " + hearts
```

**Explicación:**
- `CanvasLayer`: Se dibuja sobre el 3D, siempre visible
- `@onready`: Referencias a nodos hijos
- Métodos de actualización llamados desde main.gd
- Sistema de corazones generado dinámicamente

---

## 4. PROBLEMAS ENCONTRADOS Y SOLUCIONES

### 4.1 PROBLEMA: Colisión del Jugador con Plataformas No Funciona

**Descripción del Problema:**
Al iniciar el juego, el personaje atravesaba las plataformas azules sin detectar colisión, cayendo infinitamente.

**Diagnóstico:**
1. Las plataformas tenían `StaticBody3D` configurado
2. Existían `CollisionShape3D` en cada plataforma
3. Sin embargo, los tamaños de las formas de colisión no coincidían con los modelos visuales

**Análisis Técnico:**
```gdscript
# Estado inicial (INCORRECTO)
[sub_resource type="BoxShape3D" id="BoxShape3D_2"]
size = Vector3(4, 2, 4)  # Muy pequeño para modelo de 8x4x8
```

El modelo `Cube_Prototype_Large_A.gltf` tiene dimensiones aproximadas de 8x4x8 unidades, pero la colisión era de 4x2x4, resultando en un volumen de colisión 8 veces menor.

**Solución Aplicada:**
```gdscript
# Corrección
[sub_resource type="BoxShape3D" id="BoxShape3D_2"]
size = Vector3(8, 4, 8)  # Coincide con el modelo
```

**Pasos de Implementación:**
1. Medición de modelos en editor 3D de Godot
2. Ajuste manual de valores en Inspector
3. Activación de "Debug > Visible Collision Shapes" para visualización
4. Prueba iterativa hasta coincidencia exacta

**Resultado:**
Colisiones funcionando correctamente, jugador camina sobre plataformas.

---

### 4.2 PROBLEMA: Jugador No Cae al Vacío

**Descripción del Problema:**
El jugador podía caminar más allá de las baldosas visibles sin caer, como si hubiera un suelo invisible.

**Diagnóstico:**
```gdscript
[node name="Ground" type="StaticBody3D"]
    [node name="CollisionShape3D"]
        shape = BoxShape3D(size: Vector3(50, 1, 50))  # DEMASIADO GRANDE
```

**Análisis:**
- Suelo visual: 9 baldosas de 10x10 = 30x30 unidades
- Colisión configurada: 50x50 unidades
- Área de colisión extra: 20x20 unidades invisibles

**Visualización del Problema:**
```
[Baldosas visibles: 30x30]
+---------------------------+
|    Área visible           |
|  +---------------------+  |
|  |     9 baldosas     |  |
|  |     (visible)      |  |
|  +---------------------+  |
|   Área invisible (BUG)    |
+---------------------------+
[Colisión: 50x50]
```

**Solución Aplicada:**
```gdscript
# Corrección del tamaño
[sub_resource type="BoxShape3D" id="BoxShape3D_1"]
size = Vector3(30, 1, 30)  # Coincide con área visual
```

**Mejora Adicional:**
Conversión de estructura monolítica a modular:
```gdscript
# Antes: Una colisión gigante compartida
Ground (StaticBody3D)
└── CollisionShape3D (50x50) - COMPARTIDO

# Después: Colisiones individuales
FloorTiles (Node3D)
├── Floor1 (StaticBody3D)
│   └── CollisionShape3D (10x10) - INDEPENDIENTE
├── Floor2 (StaticBody3D)
│   └── CollisionShape3D (10x10) - INDEPENDIENTE
└── Floor3-9...
```

**Beneficios:**
- Cada baldosa es independiente
- Permite modificar colisiones individuales
- Facilita añadir/remover baldosas dinámicamente
- Mejor organización del código

---

### 4.3 PROBLEMA: Plataformas Comparten la Misma Forma de Colisión

**Descripción del Problema:**
Al intentar ajustar el tamaño de colisión de Platform1 en el Inspector, todas las plataformas (Platform1, Platform2, Platform3) se modificaban simultáneamente.

**Diagnóstico:**
```gdscript
# Configuración inicial (INCORRECTA)
[sub_resource type="BoxShape3D" id="BoxShape3D_2"]
size = Vector3(8, 4, 8)

[node name="Platform1"]
    [node name="CollisionShape3D"]
        shape = SubResource("BoxShape3D_2")  # Referencia compartida

[node name="Platform2"]
    [node name="CollisionShape3D"]
        shape = SubResource("BoxShape3D_2")  # MISMA referencia

[node name="Platform3"]
    [node name="CollisionShape3D"]
        shape = SubResource("BoxShape3D_2")  # MISMA referencia
```

**Análisis Técnico:**
En Godot, los `SubResource` son objetos de recursos. Cuando múltiples nodos referencian el mismo SubResource por ID, todos comparten la misma instancia en memoria. Modificar propiedades del recurso afecta a todas las referencias.

**Concepto de Recursos Compartidos:**
```
Memoria:
+------------------+
| BoxShape3D_2     |
| size = (8,4,8)   |
+------------------+
     ↑   ↑   ↑
     |   |   |
  Plat1 Plat2 Plat3
```

**Solución Aplicada:**
Crear recursos individuales para cada plataforma:

```gdscript
# Recursos únicos
[sub_resource type="BoxShape3D" id="BoxShape3D_2"]
size = Vector3(8, 4, 8)

[sub_resource type="BoxShape3D" id="BoxShape3D_3"]
size = Vector3(8, 4, 8)

[sub_resource type="BoxShape3D" id="BoxShape3D_4"]
size = Vector3(8, 4, 8)

# Asignación individual
[node name="Platform1"]
    [node name="CollisionShape3D"]
        shape = SubResource("BoxShape3D_2")  # Único

[node name="Platform2"]
    [node name="CollisionShape3D"]
        shape = SubResource("BoxShape3D_3")  # Único

[node name="Platform3"]
    [node name="CollisionShape3D"]
        shape = SubResource("BoxShape3D_4")  # Único
```

**Resultado:**
```
Memoria:
+----------------+   +----------------+   +----------------+
| BoxShape3D_2   |   | BoxShape3D_3   |   | BoxShape3D_4   |
| size=(8,4,8)   |   | size=(8,4,8)   |   | size=(8,4,8)   |
+----------------+   +----------------+   +----------------+
        ↑                    ↑                    ↑
     Plat1                Plat2                Plat3
```

Ahora cada plataforma puede modificarse independientemente.

---

### 4.4 PROBLEMA: Sistema de Gravedad Inconsistente

**Descripción del Problema:**
El jugador a veces no caía inmediatamente al salir de una plataforma, experimentando un breve "flotar" antes de caer.

**Código Original:**
```gdscript
func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= gravity * delta
```

**Análisis del Problema:**
La gravedad solo se aplicaba cuando `is_on_floor()` retornaba `false`. Sin embargo, hay un frame de transición donde el jugador ya no está en el suelo pero Godot aún no ha actualizado el estado de colisión.

**Diagrama del Bug:**
```
Frame N:   is_on_floor() = true  → No aplica gravedad
Frame N+1: Jugador sale de plataforma
           is_on_floor() = true (aún) → No aplica gravedad (BUG)
Frame N+2: is_on_floor() = false → Aplica gravedad
```

**Solución Aplicada:**
```gdscript
func _physics_process(delta):
    # Resetear velocidad Y si está en suelo
    if is_on_floor():
        if velocity.y < 0:
            velocity.y = 0
    else:
        # Aplicar gravedad siempre que esté en el aire
        velocity.y -= gravity * delta
```

**Explicación de la Mejora:**
1. Si está en el suelo Y tiene velocidad descendente: resetea a 0
2. Si NO está en el suelo: siempre aplica gravedad
3. Elimina el frame de transición problemático

**Física Correcta:**
```
Ecuación de movimiento:
v(t) = v₀ - g·t
y(t) = y₀ + v₀·t - ½g·t²

Donde:
v(t) = velocidad en tiempo t
v₀ = velocidad inicial
g = gravedad (20.0)
t = tiempo (delta acumulado)
```

---

### 4.5 PROBLEMA: Colisión de Monedas No Detecta al Jugador

**Descripción del Problema:**
El jugador podía atravesar monedas sin recolectarlas.

**Diagnóstico Inicial:**
```gdscript
# Moneda (Area3D)
collision_layer = 0  # No especificada
collision_mask = 0   # No detecta nada

# Jugador (CharacterBody3D)
collision_layer = 0  # No especificada
collision_mask = 0   # No detecta nada
```

**Análisis del Sistema de Capas:**
Godot usa un sistema de máscaras de bits para colisiones:
- `collision_layer`: En qué capa(s) está el objeto
- `collision_mask`: Qué capa(s) puede detectar el objeto

**Tabla de Verdad de Colisión:**
```
Objeto A en Capa X
Objeto B detecta Capa X
→ Objeto B detecta a Objeto A

Si ambos tienen mask=0 y layer=0:
→ NO HAY DETECCIÓN
```

**Solución Aplicada:**
```gdscript
# Sistema de capas definido
Capa 1 (bit 0): Plataformas (StaticBody3D)
Capa 2 (bit 1): Jugador (CharacterBody3D)
Capa 3 (bit 2): Items (Area3D)

# Configuración de Moneda
[node name="Coin" type="Area3D"]
collision_layer = 4      # 2² = 4 (Capa 3)
collision_mask = 2       # 2¹ = 2 (Detecta Capa 2)

# Configuración de Jugador
[node name="Player" type="CharacterBody3D"]
collision_layer = 2      # 2¹ = 2 (Capa 2)
collision_mask = 1       # 2⁰ = 1 (Detecta Capa 1)
```

**Representación Binaria:**
```
Jugador:
layer = 2  = 0b0010  (está en capa 2)
mask  = 1  = 0b0001  (detecta capa 1)

Moneda:
layer = 4  = 0b0100  (está en capa 3)
mask  = 2  = 0b0010  (detecta capa 2)

Operación AND:
Moneda.mask & Jugador.layer = 0b0010 & 0b0010 = 0b0010 (TRUE)
→ Moneda DETECTA Jugador
```

**Resultado:**
Sistema de detección funcionando correctamente mediante señal `body_entered`.

---

### 4.6 PROBLEMA: Exportación Falla con Errores de UID

**Descripción del Problema:**
Al exportar el proyecto a ejecutable Windows, aparecían warnings en consola:
```
WARNING: ext_resource, invalid UID: uid://ddajw7cq3lxej
WARNING: ext_resource, invalid UID: uid://bhj2oe7ljw5xj
```

El ejecutable no cargaba correctamente, quedándose en pantalla negra.

**Diagnóstico:**
Los archivos `.tscn` referenciaban modelos 3D con UIDs (Unique Identifiers) que no coincidían con los UIDs reales en los archivos `.import`.

**Análisis del Sistema de UIDs:**
Godot genera un UID único para cada recurso importado:
```
Archivo original: Coin_A.gltf
Archivo .import:  Coin_A.gltf.import
UID generado:     uid://ddgvs8bjyxyih

Referencia en scene: uid://ddajw7cq3lxej  (INCORRECTO)
```

**Causa Raíz:**
Los UIDs cambian cuando:
1. Se reimportan assets
2. Se mueven archivos
3. Se copia el proyecto a otra ubicación
4. Se regenera la carpeta `.godot`

**Verificación del UID Correcto:**
```gdscript
# Contenido de Coin_A.gltf.import
[remap]
importer="scene"
type="PackedScene"
uid="uid://ddgvs8bjyxyih"  ← UID real
path="res://.godot/imported/Coin_A.gltf-[hash].scn"
```

**Solución Aplicada:**
Actualización de referencias con UIDs correctos:

```gdscript
# coin.tscn - ANTES
[ext_resource type="PackedScene" 
              uid="uid://ddajw7cq3lxej" 
              path="res://KayKit.../Coin_A.gltf" id="2"]

# coin.tscn - DESPUÉS
[ext_resource type="PackedScene" 
              uid="uid://ddgvs8bjyxyih" 
              path="res://KayKit.../Coin_A.gltf" id="2"]

# player.tscn - ANTES
[ext_resource type="PackedScene" 
              uid="uid://bhj2oe7ljw5xj" 
              path="res://KayKit.../Dummy_Base.gltf" id="2"]

# player.tscn - DESPUÉS
[ext_resource type="PackedScene" 
              uid="uid://v8608svmrici" 
              path="res://KayKit.../Dummy_Base.gltf" id="2"]
```

**Proceso de Corrección:**
1. Localizar archivos `.import` de los modelos problemáticos
2. Extraer UID real de cada archivo
3. Actualizar referencias en archivos `.tscn`
4. Recargar proyecto en Godot
5. Verificar que no haya warnings
6. Exportar nuevamente

**Configuración de Exportación Correcta:**
```ini
# export_presets.cfg
[preset.0]
name="Windows Desktop"
export_filter="all_resources"  # Incluir todos los recursos
include_filter=""
exclude_filter=""              # No excluir nada crítico
```

**Verificación Post-Exportación:**
```
build/
├── PlatformGame3D.exe    (ejecutable)
└── PlatformGame3D.pck    (recursos empaquetados)
```

**Prevención Futura:**
1. No mover archivos manualmente, usar sistema de archivos de Godot
2. Mantener archivos `.import` en control de versiones
3. Reconstruir importaciones después de clonar proyecto
4. Usar paths relativos `res://` en lugar de UIDs cuando sea posible

---

### 4.7 PROBLEMA: Contador de Vidas No Se Actualiza Visualmente

**Descripción del Problema:**
Al implementar el sistema de vidas, el contador no aparecía en el HUD.

**Diagnóstico:**
```gdscript
# hud.gd - Script correcto
@onready var lives_label = $MarginContainer/VBoxContainer/LivesLabel

# hud.tscn - FALTA EL NODO
VBoxContainer
└── ScoreLabel  ← Existe
# LivesLabel ← NO EXISTE
```

**Análisis:**
El script referenciaba un nodo (`LivesLabel`) que no existía en la escena, causando que `lives_label` fuera `null`.

**Solución Aplicada:**
Añadir nodo `LivesLabel` en la escena HUD:

```gdscript
[node name="VBoxContainer" type="VBoxContainer" parent="MarginContainer"]

[node name="ScoreLabel" type="Label" parent="MarginContainer/VBoxContainer"]
text = "Monedas: 0"

[node name="LivesLabel" type="Label" parent="MarginContainer/VBoxContainer"]
theme_override_colors/font_color = Color(1, 0.2, 0.2)
theme_override_font_sizes/font_size = 32
text = "Vidas: ♥ ♥ ♥"
```

**Función de Actualización:**
```gdscript
func update_lives(lives):
    var hearts = ""
    for i in range(lives):
        hearts += "♥ "
    lives_label.text = "Vidas: " + hearts
```

**Visualización Resultante:**
```
Monedas: 0       (Amarillo)
Vidas: ♥ ♥ ♥     (Rojo)
Controles...     (Blanco)
```

---

### 4.8 PROBLEMA: Respawn Causa Pérdida Infinita de Vidas

**Descripción del Problema:**
Al caer al vacío, el jugador reaparecía pero inmediatamente volvía a caer, perdiendo todas las vidas en un segundo.

**Código Problemático:**
```gdscript
func respawn():
    global_position = spawn_position  # Y = 1.5
    # velocity.y NO se resetea, mantiene velocidad de caída
    lose_life()
```

**Análisis del Bug:**
```
1. Jugador cae: velocity.y = -30 (descendiendo rápido)
2. Respawn: position.y = 1.5, velocity.y = -30 (aún descendiendo)
3. Próximo frame: position.y = 1.5 + (-30 * delta) = 0.9
4. Siguiente frame: position.y = 0.9 + (-30 * delta) = 0.3
5. Cae nuevamente: position.y < -20 → Respawn infinito
```

**Solución Aplicada:**
```gdscript
func respawn():
    var main = get_tree().get_first_node_in_group("main")
    if main:
        main.lose_life()
    
    global_position = spawn_position
    velocity = Vector3.ZERO  ← CRÍTICO: Resetear velocidad
    print("¡Respawn! Perdiste una vida")
```

**Por Qué Funciona:**
- `velocity = Vector3.ZERO` resetea velocidad en X, Y, Z
- Velocidad Y = 0 significa que no hay movimiento vertical
- La gravedad se aplicará gradualmente desde 0
- El jugador tiene tiempo de aterrizar en la plataforma

**Física del Respawn Correcto:**
```
Frame 0: Respawn
  position = (0, 1.5, 0)
  velocity = (0, 0, 0)

Frame 1: Gravedad aplicada
  velocity.y = 0 - (20 * 0.016) = -0.32
  position.y = 1.5 + (-0.32 * 0.016) = 1.495

Frame 2: Detecta suelo
  is_on_floor() = true
  velocity.y = 0
  ESTABLE
```

---

## 5. CONCLUSIONES

### 5.1 Logros del Proyecto

1. **Implementación Exitosa de Mecánicas 3D**
   - Sistema de movimiento fluido con física realista
   - Control de cámara en tercera persona
   - Detección de colisiones precisa

2. **Sistema de Juego Completo**
   - Menú principal funcional
   - Sistema de puntuación con recolección de items
   - Sistema de vidas con Game Over
   - Pantalla de victoria al completar objetivo

3. **Arquitectura Modular**
   - Código organizado en scripts separados
   - Comunicación entre nodos mediante grupos y señales
   - Fácil mantenimiento y expansión

4. **Integración de Assets Externos**
   - Uso exitoso de modelos 3D GLTF
   - Sistema de importación configurado correctamente
   - Exportación funcional del proyecto

### 5.2 Desafíos Técnicos Superados

1. **Sistema de Colisiones**
   - Comprensión profunda del sistema de capas
   - Ajuste preciso de formas de colisión
   - Debugging con herramientas de visualización

2. **Gestión de Escenas**
   - Transiciones suaves entre escenas
   - Manejo correcto de pausas y estados
   - Creación dinámica de UI

3. **Física 3D**
   - Implementación correcta de gravedad
   - Sistema de respawn robusto
   - Detección confiable de suelo

4. **Exportación**
   - Resolución de problemas de UIDs
   - Configuración correcta de presets
   - Empaquetado de recursos

### 5.3 Conocimientos Adquiridos

**Técnicos:**
- Programación en GDScript
- Sistema de nodos de Godot
- Física 3D y CharacterBody3D
- Sistemas de colisión por capas
- Manejo de señales y eventos
- Coroutines con await

**De Diseño:**
- Arquitectura de juegos
- Patrones de comunicación entre componentes
- Gestión de estado del juego
- Diseño de interfaces

**De Debugging:**
- Uso de herramientas de depuración de Godot
- Técnicas de logging
- Visualización de colisiones
- Análisis de comportamiento físico

### 5.4 Áreas de Mejora Futura

1. **Gameplay**
   - Añadir enemigos con IA
   - Implementar power-ups
   - Crear múltiples niveles
   - Sistema de puntuación por tiempo

2. **Audio**
   - Efectos de sonido para acciones
   - Música de fondo
   - Sonido espacial 3D

3. **Visuales**
   - Partículas para efectos
   - Animaciones de personaje
   - Post-procesamiento visual
   - Mejor iluminación

4. **Optimización**
   - Occlusion culling
   - LOD para modelos distantes
   - Compresión de assets
   - Reducción de drawcalls

### 5.5 Aplicabilidad del Conocimiento

Los conceptos aprendidos son aplicables a:
- Desarrollo de juegos 3D en general
- Simulaciones físicas
- Aplicaciones interactivas 3D
- Visualización arquitectónica
- Entrenamiento virtual

### 5.6 Reflexión Final

Este proyecto ha demostrado la viabilidad de crear un juego 3D funcional utilizando Godot Engine, superando múltiples desafíos técnicos mediante análisis sistemático y soluciones bien fundamentadas. La experiencia adquirida en debugging, optimización y arquitectura de software es directamente transferible a proyectos más complejos.

El proceso iterativo de encontrar problemas, diagnosticarlos y aplicar soluciones ha reforzado la importancia de:
- Documentación detallada
- Testing continuo
- Metodología estructurada de resolución de problemas

---

## REFERENCIAS

### Documentación Oficial
- Godot Engine Documentation 4.5: https://docs.godotengine.org/en/stable/
- GDScript Reference: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
- 3D Tutorial: https://docs.godotengine.org/en/stable/tutorials/3d/

### Assets Utilizados
- KayKit Prototype Bits 1.1 (Free)
- Licencia: CC0 (Dominio Público)

### Herramientas
- Godot Engine 4.5
- Visual Studio Code (para edición de scripts)
- Git (control de versiones)

---

**Carlos Fabian Leyva Gómez - 218522926**
