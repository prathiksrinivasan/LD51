extends Node2D

const gemTile = preload("res://Tile.tscn")
export(int) var width = 20
export(int) var height = 10
export(int) var tileSize = 50
var boardTiles := []
var boardState := []



# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(width):
		boardState.append([])
		if(i<width/2):	
			boardTiles.append([])
		for j in range(height):
			boardState[i].append(0)
			if(i<width/2):
				_addTile(i)
	
	
func _addTile(col):
	var newTile = gemTile.instance()
	var row = boardTiles[col].size()
	boardState[col][row] = newTile.id
	newTile.set_size(Vector2(tileSize,tileSize))
	newTile.position = Vector2(col*tileSize*1.1,row*tileSize*1.1)
	newTile.gridPos = Vector2(col,row)
	newTile.connect("tileClicked",self, "_onTileClicked")
	boardTiles[col].append(newTile)
	add_child(newTile)
	

func _onTileClicked(tile):
	boardState[tile.gridPos.x][tile.gridPos.y] = 0
	var deletedTile = boardTiles[tile.gridPos.x].pop_at(tile.gridPos.y)
	_updateTiles()	
	deletedTile.queue_free()
	
func _updateTiles():
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
						for j in range(boardTiles[i].size()):
							boardTiles[i][j].gridPos = Vector2(i,j)
	for i in range(width-1):
		if(_arraySum(boardState[i]) == 0):
			var temp = boardState[i].duplicate()
			boardState[i] = boardState[i+1]
			boardState[i+1] = temp
	#adjust board tile array to reflect board state
	while(boardTiles.has([])):
		boardTiles.erase([])
	for k in range(boardTiles.size()):
		for j in range(boardTiles[k].size()):
			boardTiles[k][j].gridPos = Vector2(k,j)
			boardTiles[k][j].drop_and_slide()
					
					
func getBlock(tilePos):
	pass
func _arraySum(array):
	var sum = 0	
	for j in range(height):
		sum += array[j]
	return sum
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
