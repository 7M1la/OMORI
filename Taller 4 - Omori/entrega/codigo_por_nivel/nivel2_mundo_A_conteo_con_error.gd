# Nivel 2 — primera versión (CON EL ERROR del conteo). Solo las partes nuevas de mundo.gd.
# Al recoger el último, el grupo "dulces" todavía tiene 1 (el dulce que avisa aún no se ha
# borrado: queue_free lo borra al final del frame), así que NUNCA aparece "¡Encontraste todo!".

var puntaje = 0
var modo_poder = false


func _ready():
	construir()                                       # primero se crean...
	for item in get_tree().get_nodes_in_group("dulces"):
		item.recogido.connect(_on_recogido)           # ...después se conectan


func _on_recogido(valor, da_poder):
	puntaje += valor
	$HUD/Puntaje.text = "Puntaje: %d" % puntaje
	if da_poder:
		activar_poder()
	var quedan = get_tree().get_nodes_in_group("dulces").size()
	print("quedan según el grupo: ", quedan)          # con el último imprime 1
	if quedan == 0:
		$HUD/Mensaje.text = "¡Encontraste todo!"


func activar_poder():
	modo_poder = true
	print("poder: sí")
	await get_tree().create_timer(8.0).timeout
	modo_poder = false
	print("poder: no")
