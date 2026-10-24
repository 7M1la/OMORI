extends "res://bloques.gd"
# El nivel se arma a partir del MAPA: cada "#" es un bloque.

const MAPA = [
	"##############",
	"#o  .    .  .#",
	"#   ##  E    #",
	"# . ##     . #",
	"#            #",
	"#  .     #  .#",
	"#  .     #   #",
	"#     .  E  o#",
	"##############",
]

const COLOR_ALGO_NORMAL = Color(1, 1, 1, 1)
const COLOR_ALGO_PODER = Color(0.35, 0.55, 1.0, 1)   # azul mientras dura el poder

var dulce_escena = preload("res://dulce.tscn")
var jugo_escena = preload("res://jugo.tscn")
var algo_escena = preload("res://algo.tscn")

var puntaje = 0
var modo_poder = false
var vidas = 3

@onready var jugador = $Omori

func _ready():
	construir()
	for item in get_tree().get_nodes_in_group("dulces"):
		item.recogido.connect(_on_recogido)
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.toco_al_jugador.connect(_on_enemigo_toco)
	$TimerPoder.timeout.connect(_on_timer_poder_timeout)

func construir():
	construir_bloques(MAPA, Color(0.15, 0.15, 0.15, 1))
	for fila in MAPA.size():
		for col in MAPA[fila].length():
			var escena = null
			match MAPA[fila][col]:
				".":
					escena = dulce_escena
				"o":
					escena = jugo_escena
				"E":
					escena = algo_escena
			if escena:
				var nodo = escena.instantiate()
				nodo.position = Vector2(col + 0.5, fila + 0.5) * CELDA
				$Mapa.add_child(nodo)
				
func _on_recogido(valor, da_poder):
	puntaje += valor
	$Marcador/Puntaje.text = "Puntaje: %d" % puntaje
	if da_poder:
		activar_poder()
	if get_tree().get_nodes_in_group("dulces").size() == 0:
		$Marcador/Mensaje.text = "¡Encontraste todo!"


# ---------- Poder del jugo ----------

# El poder usa un Timer: si recoges otro jugo, start() vuelve a poner los 8 s.
func activar_poder():
	modo_poder = true
	$TimerPoder.start()
	pintar_algos(COLOR_ALGO_PODER)
	print("poder: sí")


func _on_timer_poder_timeout():
	modo_poder = false
	pintar_algos(COLOR_ALGO_NORMAL)
	print("poder: no")


func pintar_algos(color: Color):
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.modulate = color
		
#funcion para  cualdo se toca a los algo
func _on_enemigo_toco(enemigo):
	#  Si Omori está asustado, o el juego ya terminó, no hacer nada.
	if jugador.asustado or vidas <= 0:
		return
	
	# si Omori tiene poder el Algo vuelve a casa y se suman 200 puntos
	if modo_poder:
		enemigo.volver_a_casa()
		puntaje += 200
		$Marcador/Puntaje.text = "Puntaje: %d" % puntaje
	#  Si omori toca al algo sin poder
	else:
		# Una vida menos.
		vidas -= 1
		# Si quedan 0, se peierde y Omori deja de moverse
		if vidas <= 0:
			$Marcador/Mensaje.text = "Perdiste"
			jugador.set_physics_process(false)
		# Si no se llama la función de asustarse
		else:
			jugador.asustarse()
