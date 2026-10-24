extends Area2D
# Nivel 2 — el dulce avisa con una señal propia en vez de sumar él mismo.

signal recogido(valor, da_poder)

@export var valor = 10
@export var da_poder = false      # en jugo.tscn: true


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.is_in_group("jugador"):
		recogido.emit(valor, da_poder)
		queue_free()
