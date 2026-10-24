extends Area2D
# Nivel 1 — Recoger dulces. Mismo script en dulce.tscn (valor 10) y jugo.tscn (valor 50 en el Inspector).

@export var valor = 10


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.is_in_group("jugador"):
		print("recogida: +", valor)
		queue_free()                        # que desaparezca
