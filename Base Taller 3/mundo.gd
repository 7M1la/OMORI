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
var dulce_escena = preload("res://dulce.tscn")
var jugo_escena = preload("res://jugo.tscn")
var algo_escena = preload("res://algo.tscn")

var puntaje = 0

func _ready():
	construir()
	for item in get_tree().get_nodes_in_group("dulces"):
		item.recogido.connect(_on_recogido)

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
				
func _on_recogido(valor):
	puntaje += valor
	$Marcador/Puntaje.text = "Puntaje: %d" % puntaje
	if get_tree().get_nodes_in_group("dulces").size() == 0:
		$Marcador/Mensaje.text = "¡Encontraste todo!"
