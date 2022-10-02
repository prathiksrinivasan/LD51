extends Node2D

const gemTile = preload("res://Tile.tscn")
const particleExplosion = preload("res://particleExplosion.tscn")
export(int) var width = 20
export(int) var height = 10
export(int) var tileSize = 50
var boardTiles := []
var boardState := []
var updatingBoard = false
signal pastLimit
signal sfxCue(sfxName)
signal score(scoreAmt)

#func _input(event):
#	if(event.is_action_pressed("ui_right")):
#		_addNewCol()
#	if(event.is_action_pressed("ui_left")):
#		nukeBoard()

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(width):
		boardState.append([])
		if(i<9):	
			boardTiles.append([])
		for j in range(height):
			boardState[i].append(0)
			if(i<9):
				_addTile(i)
	_updateTiles()
	
	
func _addTile(col):
	var newTile = gemTile.instance()
	var row = boardTiles[col].size()
	boardState[col][row] = newTile.id
	newTile.set_size(Vector2(tileSize,tileSize))
	newTile.position = Vector2((col-1)*tileSize*1.1,row*tileSize*1.1)
	newTile.gridPos = Vector2(col,row)
	newTile.connect("tileClicked",self, "_onTileClicked")
	boardTiles[col].append(newTile)
	add_child(newTile)
	

func _onTileClicked(tile):
	#boardState[tile.gridPos.x][tile.gridPos.y] = 0
	#var deletedTile = boardTiles[tile.gridPos.x].pop_at(tile.gridPos.y)
	#deletedTile.queue_free()
	var block = getBlock(tile.gridPos)
	if(block.size() < 2):
		#signal here
		emit_signal("sfxCue", "res://sounds/wrong.wav")
	else:
		emit_signal("sfxCue", "res://sounds/shot.wav")
		emit_signal("score",calcScore(block))
		var dummyTile = gemTile.instance()
		var deletedTiles = []
		for i in block:
			addExplosion(i)
			boardState[i.x][i.y] = 0
			deletedTiles.append(boardTiles[i.x][i.y])
			boardTiles[i.x][i.y] = dummyTile
		for i in deletedTiles:
			i.queue_free()
		for i in boardTiles:
			for j in range(i.count(dummyTile)):
				i.erase(dummyTile)
		_updateTiles()
	
func _updateTiles():
	updatingBoard = true
	#adjust board tile array to reflect board state
	while(boardTiles.has([])):
		boardTiles.erase([])
	#loop through boardstate
	#bubble sort the 0s up to the top in each col
	#if a column is all 0s and the column in front of it isn't, move that column back
	#change the boardtile gridpos to boardstate index

	#behold probably an extremely inefficient implementation of the above pseudocode
	#it works though
	for i in range(width):
		if _arraySum(boardState[i]) != 0:
			for k in range(height):
				for k2 in range(height-1):
					if(boardState[i][k2] == 0):
						boardState[i][k2] = boardState[i][k2+1]
						boardState[i][k2+1] = 0
						if(i<boardTiles.size()):
							for j in range(boardTiles[i].size()):
								boardTiles[i][j].gridPos = Vector2(i,j)
	for i in range(width-1):
		if(_arraySum(boardState[i]) == 0):
			var temp = boardState[i].duplicate()
			boardState[i] = boardState[i+1]
			boardState[i+1] = temp
	
	for k in range(boardTiles.size()):
		for j in range(boardTiles[k].size()):
			boardTiles[k][j].gridPos = Vector2(k,j)
			boardTiles[k][j].drop_and_slide()
	updatingBoard = false
					
func getBlock(tilePos):
	#flood fill algorithm variation
	var stack = []
	var out = []
	var ogID = boardState[tilePos.x][tilePos.y]
	stack.push_back(tilePos)
	while(!stack.empty() and ogID != 0):
		var pos = stack.pop_back()
		if(!out.has(pos)):
			out.append(pos)
			if(pos.x > 0):
				if(boardState[pos.x-1][pos.y] == ogID):
					stack.push_back(Vector2(pos.x-1,pos.y))
			if(pos.x < width-1):
				if(boardState[pos.x+1][pos.y] == ogID):
					stack.push_back(Vector2(pos.x+1,pos.y))
			if(pos.y > 0):
				if(boardState[pos.x][pos.y-1] == ogID):
					stack.push_back(Vector2(pos.x,pos.y-1))
			if(pos.y < height-1):
				if(boardState[pos.x][pos.y+1] == ogID):
					stack.push_back(Vector2(pos.x,pos.y+1))
	return out
	
	
func _arraySum(array):
	var sum = 0	
	for j in range(height):
		sum += array[j]
	return sum
	
func _addNewCol():
	boardTiles.push_front([])
	var t = []
	for i in range(height):
		t.append(0)
	boardState.push_front(t)
	var n = boardState.pop_back()
	if(_arraySum(n)>0):
		emit_signal("pastLimit")
	for i in range(height):
		_addTile(0)
		
	_updateTiles()
	emit_signal("sfxCue","res://sounds/newCol.wav")
	
func _updateIDs(newIDX):
	#I am pretty sure this is a terrible idea but I have no idea what im doing
	if(updatingBoard):
		_updateIDs(newIDX)
	else:
		for i in boardTiles:
			for j in i:
				j.id = j.attributes[newIDX]
				if(j.gridPos.x < width):
					boardState[j.gridPos.x][j.gridPos.y] = j.id
				
func addExplosion(i):
	var particle = particleExplosion.instance()
	particle.position = boardTiles[i.x][i.y].position
	particle.process_material.color = boardTiles[i.x][i.y].self_modulate
	add_child(particle)
	
func nukeBoard():
	var gone = []
	for i in boardTiles:
		for j in i:
			gone.append(j)
			addExplosion(j.gridPos)
	for i in gone:
		i.queue_free()
	boardTiles.clear()
	for i in range(boardState.size()):
		for j in range(boardState[i].size()):
			boardState[i][j] = 0
	
	emit_signal("sfxCue","res://sounds/sound.wav")
	
func calcScore(block):
	var gems = block.size()
	return gems*20*(1+(.5*(gems-2)))
	
