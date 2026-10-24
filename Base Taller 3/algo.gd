extends Area2D

signal toco_al_jugador(algo)

@onready var x_inicial = position.x

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("omori"):
		toco_al_jugador.emit(self)

func volver_a_casa():
	position.x = x_inicial
