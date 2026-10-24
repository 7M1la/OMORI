extends Area2D
# Lo usan dulce.tscn (valor 10) y jugo.tscn (valor 50, da_poder = true).
# El dulce NO suma el puntaje: solo avisa con una señal y desaparece.
# El Mundo, que guarda el único puntaje, decide qué hacer con el aviso.

signal recogido(valor, da_poder)

@export var valor = 10
@export var da_poder = false


func _ready():
	body_entered.connect(_on_body_entered)   # conectada solo por código (no en el editor)


func _on_body_entered(body):
	# body es el Omori (CharacterBody2D): es el único de sus nodos que es un cuerpo físico.
	if body.is_in_group("jugador"):
		print("recogida: +", valor)
		recogido.emit(valor, da_poder)
		queue_free()                         # se borra al final del frame
