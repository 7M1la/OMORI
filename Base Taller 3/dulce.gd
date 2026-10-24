extends Area2D

# Señal para avisar al mundo el valor recogido y si otorga poder
signal recogido(valor)

@export var valor = 10


func _ready():
	body_entered.connect(_on_body_entered)

	
func _on_body_entered(body):
	if body.is_in_group("omori"):
		#print("recogida: +", valor)
		remove_from_group("dulces") #eliminar del grupo dulces :p
		recogido.emit(valor) #para emitir la señal de que se recogio
		queue_free() #para que desaparexca el dulce
