extends "res://bloques.gd"
# Taller 4 — Las reglas de Omori (niveles 1, 2, 3 y extras).
# construir() arma el nivel a partir del MAPA:
# "#" bloque, "." dulce, "o" jugo, "E" algo (vaivén horizontal), "V" algo (vaivén vertical, Extra 2).
# El Mundo es quien sabe más: guarda puntaje, vidas y poder, y decide qué pasa con cada aviso.

const MAPA = [
	"##############",
	"#o  .    .  .#",
	"#   ##  V    #",
	"# . ##     . #",
	"#            #",
	"#  .     #  .#",
	"#  .     #   #",
	"#     .  E  o#",
	"##############",
]

const COLOR_ALGO_NORMAL = Color(1, 1, 1, 1)
const COLOR_ALGO_PODER = Color(0.35, 0.55, 1.0, 1)   # Extra 1: azul mientras dura el poder

var dulce_escena = preload("res://dulce.tscn")
var jugo_escena = preload("res://jugo.tscn")
var algo_escena = preload("res://algo.tscn")

var puntaje = 0
var vidas = 3
var modo_poder = false
var restantes = 0          # contador propio para la victoria (arreglo del nivel 2)
var terminado = false      # true al ganar o perder

@onready var jugador = $Omori


func _ready():
	construir()   # primero se crean los dulces y los Algos; después se conectan sus señales
	for item in get_tree().get_nodes_in_group("dulces"):
		item.recogido.connect(_on_recogido)
	restantes = get_tree().get_nodes_in_group("dulces").size()
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.toco_al_jugador.connect(_on_enemigo_toco)
	$TimerPoder.timeout.connect(_on_timer_poder_timeout)
	print("Para recoger: ", restantes, " | Algos: ", get_tree().get_nodes_in_group("enemigos").size())
	actualizar_hud()


func construir():
	construir_bloques(MAPA, Color(0.15, 0.15, 0.15, 1))
	for fila in MAPA.size():
		for col in MAPA[fila].length():
			var escena = null
			var es_vertical = false
			match MAPA[fila][col]:
				".":
					escena = dulce_escena
				"o":
					escena = jugo_escena
				"E":
					escena = algo_escena
				"V":
					escena = algo_escena
					es_vertical = true
			if escena:
				var nodo = escena.instantiate()
				nodo.position = Vector2(col + 0.5, fila + 0.5) * CELDA
				if es_vertical:
					nodo.vertical = true
					nodo.distancia = 64.0
				$Mapa.add_child(nodo)


# ---------- Nivel 2: dulces, poder y victoria ----------

func _on_recogido(valor, da_poder):
	puntaje += valor
	restantes -= 1
	# El grupo todavía incluye el dulce que avisa (queue_free lo borra al final del frame):
	print("quedan según el grupo: ", get_tree().get_nodes_in_group("dulces").size(),
			" | según el contador: ", restantes)
	if da_poder:
		activar_poder()
	if restantes == 0 and not terminado:
		terminado = true
		$HUD/Mensaje.text = "¡Encontraste todo!"
		print("victoria con puntaje ", puntaje)
	actualizar_hud()


# Nivel 3: el poder usa un Timer (una sola alarma que start() vuelve a poner en 8 s).
func activar_poder():
	modo_poder = true
	$TimerPoder.start()
	pintar_algos(COLOR_ALGO_PODER)
	print("poder: sí (t = %.2f s)" % tiempo())


func _on_timer_poder_timeout():
	modo_poder = false
	pintar_algos(COLOR_ALGO_NORMAL)
	print("poder: no (t = %.2f s)" % tiempo())


# ---------- Nivel 3: Algos y vidas ----------

func _on_enemigo_toco(enemigo):
	# 1. Si Omori está asustado, o el juego ya terminó, no hagan nada.
	if jugador.asustado or terminado:
		print("toque ignorado (asustado=", jugador.asustado, ", terminado=", terminado, ")")
		return
	# 2. Con poder: el Algo vuelve a casa y suman 200.
	if modo_poder:
		enemigo.volver_a_casa()
		puntaje += 200
		print("¡Algo espantado! +200")
	# 3. Sin poder:
	else:
		vidas -= 1
		print("Algo tocó a Omori. Vidas: ", vidas)
		if vidas <= 0:
			vidas = 0
			terminado = true
			$HUD/Mensaje.text = "Perdiste"
			detener_jugador()
		else:
			jugador.asustarse()   # pone asustado = true antes de su await
	# 4. Actualicen el HUD.
	actualizar_hud()


func detener_jugador():
	jugador.set_physics_process(false)
	jugador.velocity = Vector2.ZERO
	jugador.pasos.stop()
	jugador.sprite.speed_scale = 1.0
	jugador.sprite.play("quieto_" + jugador.nombre_vista(jugador.mirando))


# ---------- Utilidades ----------

func actualizar_hud():
	$HUD/Puntaje.text = "Puntaje: %d" % puntaje
	$HUD/Vidas.text = "Vidas: %d" % vidas


func pintar_algos(color: Color):
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.modulate = color


func tiempo() -> float:
	return Time.get_ticks_msec() / 1000.0
