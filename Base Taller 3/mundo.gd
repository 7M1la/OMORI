extends "res://bloques.gd"

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
const COLOR_ALGO_PODER = Color(0.35, 0.55, 1.0, 1)  

var dulce_escena = preload("res://dulce.tscn")
var jugo_escena = preload("res://jugo.tscn")
var algo_escena = preload("res://algo.tscn")

var puntaje = 0
var modo_poder = false
var vidas = 3
var dulcesRestantes = 0

@onready var jugador = $Omori


func _ready():
	construir()

	var lista_dulces = get_tree().get_nodes_in_group("dulces")
	dulcesRestantes = lista_dulces.size()


	for item in lista_dulces:
		item.recogido.connect(_on_recogido)

	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.toco_al_jugador.connect(_on_enemigo_toco)


	$TimerPoder.timeout.connect(_on_timer_poder_timeout)
	actualizar_hud()   # muestra "Puntaje: 0" y "Vidas: 3" al iniciar


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
	actualizar_hud()
	if da_poder:
		activar_poder()
	dulcesRestantes -= 1
	if dulcesRestantes <= 0: 
		$Marcador/Mensaje.text = "¡Encontraste todo!"

func activar_poder():
	modo_poder = true
	$TimerPoder.start()
	pintar_algos(COLOR_ALGO_PODER)
	print("poder: sí (t = %.2f s)" % tiempo())


func _on_timer_poder_timeout():
	modo_poder = false
	pintar_algos(COLOR_ALGO_NORMAL)
	print("poder: no (t = %.2f s)" % tiempo())


func pintar_algos(color: Color):
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.modulate = color


func tiempo() -> float:
	return Time.get_ticks_msec() / 1000.0



func _on_enemigo_toco(enemigo):
	
	if jugador.asustado or vidas <= 0:
		return

	
	if modo_poder:
		enemigo.volver_a_casa()
		puntaje += 200
	else:
		
		vidas -= 1
		
		if vidas <= 0:
			$Marcador/Mensaje.text = "Perdiste"
			jugador.set_physics_process(false)
		else:
			jugador.asustarse()
	actualizar_hud()   # refresca puntaje y vidas después de cada toque

func actualizar_hud():
	$Marcador/Puntaje.text = "Puntaje: %d" % puntaje
	$Marcador/Vidas.text = "Vidas: %d" % vidas
