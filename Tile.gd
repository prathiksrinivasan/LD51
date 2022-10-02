extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var hovered = false
onready var lastHovered = false
var attributes = [0,0,0]
var id = 0
var size = Vector2()
var gridPos = Vector2()
var spacing = 55
var shapes = {1:preload("res://sprites/shape1.png"),2:preload("res://sprites/shape2.png"),3:preload("res://sprites/shape3.png"),4:preload("res://sprites/shape4.png"),5:preload("res://sprites/shape5.png")}
var colors = {1:Color8(255,55,55,255),2:Color8(63,218,36,255),3:Color8(88,134,255,255),4:Color8(255,227,71,255),5:Color("ee5cff")}
var eyes = {1:preload("res://sprites/eyes1.png"),2:preload("res://sprites/eyes2.png"),3:preload("res://sprites/eyes3.png"),4:preload("res://sprites/eyes4.png"),5:preload("res://sprites/eyes5.png")}
signal tileClicked(tile)

# Called when the node enters the scene tree for the first time.
func _init():
	attributes[0] = randi()%5+1
	attributes[1] = randi()%5+1
	attributes[2] = randi()%5+1
	id = attributes[0]

func _ready():
	self.texture = shapes[attributes[0]]
	self.self_modulate = colors[attributes[1]]
	$Eyes.texture = eyes[attributes[2]]
	
func _physics_process(delta):
	if(lastHovered != hovered):
		if(hovered):
			material.set_shader_param("color",Color(255,255,255,255))
		else:
			material.set_shader_param("color",Color(255,255,255,0))
		lastHovered = hovered
#	if(gridPos != position):
#		position = Vector2(gridPos.x*50*1.1,gridPos.y*50*1.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if !hovered:
		return
	if event.is_action_pressed("ui_accept"):
		print(id)
		emit_signal("tileClicked",self)

func _on_Area2D_mouse_entered():
	hovered = true


func _on_Area2D_mouse_exited():
	hovered = false
	
func set_size(new_size: Vector2):
	size = new_size
	#print(size/texture.get_size())
	scale = size / texture.get_size() 

func drop_and_slide():
	if(gridPos != position):
		var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self,"position",Vector2(position.x,gridPos.y*spacing),.3)
		if(gridPos.x*spacing != position.x):
			tween.tween_property(self,"position",Vector2(gridPos.x*spacing,gridPos.y*spacing),.3)
		

			
