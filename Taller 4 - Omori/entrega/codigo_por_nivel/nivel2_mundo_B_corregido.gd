# Nivel 2 — versión CORREGIDA: contador propio "restantes".

var puntaje = 0
var modo_poder = false
var restantes = 0


func _ready():
	construir()
	for item in get_tree().get_nodes_in_group("dulces"):
		item.recogido.connect(_on_recogido)
	restantes = get_tree().get_nodes_in_group("dulces").size()   # 11


func _on_recogido(valor, da_poder):
	puntaje += valor
	restantes -= 1
	$HUD/Puntaje.text = "Puntaje: %d" % puntaje
	if da_poder:
		activar_poder()
	if restantes == 0:
		$HUD/Mensaje.text = "¡Encontraste todo!"


func activar_poder():
	modo_poder = true
	print("poder: sí")
	await get_tree().create_timer(8.0).timeout       # (en el nivel 3 se cambia por un Timer)
	modo_poder = false
	print("poder: no")
