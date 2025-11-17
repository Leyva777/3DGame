#  Platform Game 3D - Juego de Plataformas en Godot 4.5

##  Descripción del Proyecto

Juego de plataformas 3D desarrollado en Godot 4.5 donde el jugador debe recolectar monedas distribuidas en diferentes plataformas del escenario. El proyecto implementa conceptos de programación 3D, físicas, colisiones y GDScript.

##  Objetivos Cumplidos

-  Importación y configuración de modelos 3D en Godot 4.5
-  Implementación de movimiento y controles para personaje 3D
-  Sistema de detección de colisiones y recolección de objetos
-  Diseño y estructura jerárquica de escenas en Godot
-  Sistema de puntuación y HUD

##  Estructura del Proyecto

```
PlatformGame3D/
├── scenes/
│   ├── player/
│   │   └── player.tscn          # Escena del jugador con CharacterBody3D
│   ├── items/
│   │   └── coin.tscn            # Escena de la moneda recolectable
│   ├── enemies/                  # (Preparado para enemigos futuros)
│   ├── main.tscn                # Escena principal del juego
│   └── hud.tscn                 # Interfaz de usuario
├── scripts/
│   ├── player.gd                # Control del jugador y cámara
│   ├── coin.gd                  # Lógica de recolección de monedas
│   ├── main.gd                  # Gestión principal del juego
│   └── hud.gd                   # Actualización de la interfaz
├── models/                       # Carpeta para modelos 3D externos
├── materials/                    # Carpeta para materiales personalizados
├── project.godot                # Configuración del proyecto
└── README.md                    # Este archivo
```

##  Controles del Juego

| Tecla | Acción |
|-------|--------|
| **W** | Mover hacia adelante |
| **S** | Mover hacia atrás |
| **A** | Mover hacia la izquierda |
| **D** | Mover hacia la derecha |
| **ESPACIO** | Saltar |
| **MOUSE** | Rotar cámara |
| **ESC** | Liberar/capturar mouse |

##  Configuración Técnica

### Motor y Renderizado
- **Motor**: Godot 4.5
- **Renderizador**: Forward+ (optimizado para 3D)
- **Resolución**: 1280x720
- **Anti-aliasing**: MSAA 3D x2

### Sistemas Implementados

#### 1. Sistema de Movimiento del Jugador (`player.gd`)
- **CharacterBody3D**: Cuerpo físico con colisiones
- **Movimiento**: Control con WASD basado en la rotación del jugador
- **Cámara**: Tercera persona con rotación libre mediante mouse
- **Salto**: Mecánica de salto con gravedad personalizada
- **Velocidad**: 7.0 unidades/segundo
- **Fuerza de salto**: 15.0 unidades

#### 2. Sistema de Monedas (`coin.gd`)
- **Area3D**: Detección de colisiones sin física
- **Rotación**: Animación visual continua
- **Detección**: Reconoce cuando el jugador entra en su área
- **Recolección**: Se elimina al ser recogida y suma puntos

#### 3. Sistema de Gestión (`main.gd`)
- **Contador de puntos**: Rastrea monedas recolectadas
- **Comunicación**: Conecta sistemas de juego con HUD
- **Victoria**: Detecta cuando se recolectan todas las monedas

#### 4. Interfaz de Usuario (`hud.gd`)
- **Contador visual**: Muestra monedas recolectadas
- **Instrucciones**: Ayuda con los controles
- **Estilo**: Texto dorado con sombras para legibilidad

##  Jerarquía de Escenas

### Main.tscn
```
Main (Node3D)
├── WorldEnvironment      # Iluminación ambiental
├── DirectionalLight3D    # Luz principal
├── Ground               # Suelo principal (50x50)
├── Platform1-3          # Plataformas flotantes
├── Player               # Personaje controlable
├── Coin1-5              # Monedas distribuidas
└── HUD                  # Interfaz de usuario
```

### Player.tscn
```
Player (CharacterBody3D)
├── MeshInstance3D       # Cápsula visual
├── CollisionShape3D     # Forma de colisión
└── CameraPivot          # Punto de rotación
    └── Camera3D         # Cámara del jugador
```

### Coin.tscn
```
Coin (Area3D)
├── MeshInstance3D       # Cilindro dorado
└── CollisionShape3D     # Detector de colisión
```

##  Cómo Ejecutar el Proyecto

1. **Abrir en Godot 4.5**:
   - Abrir Godot 4.5
   - Seleccionar "Importar" y navegar a la carpeta del proyecto
   - Abrir `project.godot`

2. **Ejecutar el juego**:
   - Presionar **F5** o clic en "Ejecutar Proyecto"
   - O presionar **F6** para ejecutar la escena actual

3. **Editar escenas**:
   - Navegar a `scenes/main.tscn` para la escena principal
   - Navegar a `scenes/player/player.tscn` para editar el jugador
   - Navegar a `scenes/items/coin.tscn` para editar las monedas

##  Conceptos Implementados

### 1. Nodos 3D
- **Node3D**: Nodo base para objetos 3D
- **CharacterBody3D**: Cuerpo físico para personajes
- **StaticBody3D**: Cuerpos estáticos (plataformas)
- **Area3D**: Detección de áreas sin física
- **Camera3D**: Cámara 3D
- **DirectionalLight3D**: Iluminación direccional

### 2. Físicas 3D
- **Gravedad**: Configurada en 20.0 unidades/s²
- **Colisiones**: CapsuleShape3D y BoxShape3D
- **move_and_slide()**: Movimiento con detección de colisiones
- **is_on_floor()**: Detección de suelo para salto

### 3. Sistema de Entrada
- **Input.get_vector()**: Captura entrada WASD
- **InputEventMouseMotion**: Rotación de cámara
- **Input.is_action_just_pressed()**: Detección de salto
- **Mouse capture**: Captura del cursor para control de cámara

### 4. Señales y Comunicación
- **Grupos**: Organización mediante add_to_group()
- **Referencias**: @onready para nodos hijos
- **Comunicación**: get_tree().get_first_node_in_group()

### 5. GDScript
- **Variables exportadas**: @export para personalización
- **Constantes**: const para valores fijos
- **Funciones ready**: Inicialización
- **Funciones process**: Actualización por frame
- **Funciones physics_process**: Actualización física

##  Materiales y Visuales

### Moneda
- **Color**: Dorado (RGB: 1, 0.843, 0)
- **Material**: StandardMaterial3D
- **Metallic**: 0.8
- **Roughness**: 0.2

### Iluminación
- **Sky**: ProceduralSkyMaterial
- **Sombras**: Habilitadas en DirectionalLight3D
- **Glow**: Activado para efectos visuales


##  Recursos de Aprendizaje

- [Documentación Oficial de Godot 4](https://docs.godotengine.org/en/stable/)
- [Tutorial 3D FPS en Godot 4](https://docs.godotengine.org/en/stable/tutorials/3d/index.html)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)

##  Desarrollo

**Fecha de creación**: Noviembre 2025  
**Versión de Godot**: 4.5  
**Lenguaje**: GDScript  
**Tipo de proyecto**: Educativo - Práctica de Programación Gráfica 3D

##  Notas Técnicas

### Optimizaciones Implementadas
- Uso de grupos para organización eficiente
- @onready para referencias optimizadas
- queue_free() para limpieza de memoria
- Uso de const para valores inmutables

### Buenas Prácticas
- Estructura de carpetas organizada
- Comentarios en código
- Nombres descriptivos de variables
- Separación de lógica por scripts

---


