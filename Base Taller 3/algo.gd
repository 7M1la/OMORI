extends Area2D
# Algo: enemigo con vaivén (como el de The Impossible Game).
# No decide nada: solo avisa "toqué al jugador". El Mundo decide qué pasa.

signal toco_al_jugador(algo)

@export var speed = 80.0         # px/s; con 0 se queda quieto
@export var distancia = 100.0     # cuánto se aleja de su punto inicial, a cada lado
@export var vertical = false      # false = vaivén horizontal, true = vertical

var inicio = Vector2.ZERO
var direccion = 1


func _ready():
	inicio = position
	body_entered.connect(_on_body_entered)


func _physics_process(delta):
	if vertical:
		position.y += speed * direccion * delta
		if abs(position.y - inicio.y) >= distancia:
			position.y = inicio.y + distancia * direccion
			direccion = -direccion
	else:
		position.x += speed * direccion * delta
		if abs(position.x - inicio.x) >= distancia:
			position.x = inicio.x + distancia * direccion
			direccion = -direccion


func volver_a_casa():
	# Lo deja en su posición inicial según corresponda
	position = inicio
	direccion = 1


func _on_body_entered(body):
	# Detecta cualquiera de los dos grupos por si acaso tu jugador se llama "jugador" u "omori"
	if body.is_in_group("jugador") or body.is_in_group("omori"):
		toco_al_jugador.emit(self)
