extends CharacterBody2D

@export var speed = 150.0          
@export var speed_correr = 240.0   

@export var pasos_por_cuadro = false

@onready var sprite = $AnimatedSprite2D
@onready var pasos = $Pasos     
@onready var susto = $Susto      

var mirando = Vector2.DOWN

var inicio = Vector2.ZERO
var asustado = false

var animacion_anterior = "" 


func _ready():
	inicio = position
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.play("quieto_abajo")
	print("Inicio de Omori: ", inicio)


func _physics_process(_delta):
	if asustado:
		return
	if Input.is_action_just_pressed("asustarse"):
		asustarse()
		return
	mover()
	actualizar_animacion()


func mover():
	var rapidez = speed_correr if Input.is_action_pressed("correr") else speed
	velocity = leer_direccion() * rapidez
	move_and_slide()


func leer_direccion() -> Vector2:
	var x = Input.get_axis("move_left", "move_right")
	var y = Input.get_axis("move_up", "move_down")
	if x != 0:
		return Vector2(x, 0)
	if y != 0:
		return Vector2(0, y)
	return Vector2.ZERO


func nombre_vista(d: Vector2) -> String:
	if d == Vector2.UP:
		return "arriba"
	if d == Vector2.DOWN:
		return "abajo"
	return "lado"


func actualizar_animacion():
	var direccion = leer_direccion()
	if direccion != Vector2.ZERO:
		mirando = direccion

	var vista = nombre_vista(mirando)
	sprite.flip_h = (mirando == Vector2.LEFT)

	var rapidez = get_real_velocity().length()
	var nombre = ""
	if rapidez > 1:
		nombre = "caminar_" + vista
		sprite.speed_scale = rapidez / speed
	else:
		nombre = "quieto_" + vista
		sprite.speed_scale = 1.0
	sprite.play(nombre)

	if nombre != animacion_anterior:
		print("anim=", nombre, "  flip_h=", sprite.flip_h, "  rapidez=", snapped(rapidez, 0.1),
				"  speed_scale=", snapped(sprite.speed_scale, 0.01))
		animacion_anterior = nombre

	actualizar_pasos(rapidez)


func actualizar_pasos(rapidez: float):
	if rapidez > 1:
		pasos.pitch_scale = rapidez / speed
		if pasos_por_cuadro:
			return   
		if not pasos.playing:
			pasos.play()
	else:
		if not pasos_por_cuadro:
			pasos.stop()



func _on_frame_changed():
	if not pasos_por_cuadro or asustado:
		return
	if sprite.animation.begins_with("caminar_") and (sprite.frame == 1 or sprite.frame == 3):
		pasos.play()


func asustarse():
	
	asustado = true
	velocity = Vector2.ZERO
	pasos.stop()


	sprite.flip_h = false
	sprite.speed_scale = 1.0
	sprite.play("asustarse")
	susto.play()
	var frame_inicio = Engine.get_physics_frames()
	var t_inicio = Time.get_ticks_msec()
	print("Susto: empieza")

	
	await sprite.animation_finished
	print("Susto: terminó en ", (Time.get_ticks_msec() - t_inicio) / 1000.0, " s, ",
			Engine.get_physics_frames() - frame_inicio, " frames de física")

	
	position = inicio
	mirando = Vector2.DOWN
	sprite.play("quieto_abajo")
	animacion_anterior = "quieto_abajo"
	asustado = false
	print("Despierta en ", position)
