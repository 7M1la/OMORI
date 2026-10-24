extends Area2D

signal recogido(valor, da_poder)

@export var valor = 10
@export var da_poder = false


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.is_in_group("omori"):
		recogido.emit(valor, da_poder)
		queue_free()
