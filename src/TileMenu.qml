import QtQuick 2.6

Rectangle {
	readonly property color color0: "#CA4AE8" //First checkerboard tile button color.
	readonly property color color1: "#FF4ED5" //Second checkerboard tile button color.
	readonly property variant borderColorLighterFactor: 0.8 //Amount to adjust checkerboardd color for non-interactive border tiles. < 1.0 to darken and > 1.0 to lighten.

	property variant tileSize: 0
	property variant tiles: []

	function reset() {
		//Move all tiles back to their original positions.
		for(var x = 0;x < tiles.length;x++)
		{
			var tile = tiles[x];
			tile.reset();
		}

		//Reset tunnel animation.
		tunnel.state = "";
	}

	id: tileMenu
	anchors.fill: parent
	color: "#00000000"

	//Tile buttons that can be clicked.
	Grid {
		id: tileGrid
		anchors.fill: parent
		leftPadding: -12
		z: 1
		//Only six of the ten columns have interactive buttons. One on the left
		//is part of the border. All of the others are on the right so when the
		//tile menu is revealed, it looks like it continues on off the edge of
		//the screen.
		columns: 10
		//Similar to above, only three of the rows contain interactive buttons.
		//The remaining two are from the top and bottom borders.
		rows: 5
	}

	//Setup a separate border grid JUST for border tiles so they get clipped.
	//The other tiles need to fall outside the menu so they can't be clipped.
	Grid {
		id: borderTileGrid
		rows: tileGrid.rows
		columns: tileGrid.columns
		anchors.fill: parent
		leftPadding: tileGrid.leftPadding
		topPadding: tileGrid.topPadding
		clip: true
		enabled: false
		z: -1
	}

	Tunnel {
		id: tunnel
		opacity: 0.0
		width: tileSize * 6
		height: tileSize * 3
		x: tileGrid.leftPadding + tileSize
		y: tileGrid.topPadding + tileSize

		color0: Qt.lighter(parent.color0,0.7);
		color1: Qt.lighter(parent.color1,0.7);
	}

	Component.onCompleted: {
		//Text placed inside each tile button. There should be exactly
		//tileGrid.columns * tileGrid.rows entries. Entries with just a single
		//space (ie. " ") are non-interactive border tiles. Entries with no
		//text (ie. "") are non-interactive buttons but still collapse with all
		//interactive button tiles.
		var refText = [
			" "," "," "," "," "," "," "," "," "," ",
			" ","", "1","2","3","4","5"," "," "," ",
			" ","", "6","7","8","9","10"," "," "," ",
			" ","Back","11","12","13","14","15"," "," "," ",
			" "," "," "," "," "," "," "," "," "," "
		];

		//Generate tile buttons procedurally with a checkerboard colored
		//pattern.
		var index = 0;
		var tileButtonComponent = Qt.createComponent("TileButton.qml");
		for(var y = 0;y < tileGrid.rows;y++)
		{
			for(var x = 0;x < tileGrid.columns;x++,index++)
			{
				var buildTile = function(parent) {
					var tileText = refText[index];
					var tileTextSize = tileText == "Back" ? "18" : "24";
					var tileClickedFunc = tileText == "Back" ? "function() { menuBarButton2.showFullscreen = false; }" : "function() { this.fallStart(); tunnel.opacity = 1.0; tunnel.state = \"playing\"; }";
					var tileFallStartCompleted = "function() { for(var x = 0;x < tileMenu.tiles.length;x++) { var tile = tileMenu.tiles[x]; if(tile == this || tile.text == \" \") continue; tile.fallFollow(this); } }";
					return Qt.createQmlObject("import QtQuick 2.3; TileButton { text: \"" + tileText + "\"; textSize: " + tileTextSize + "; width: tileMenu.tileSize; height: tileMenu.tileSize; onClicked: " + tileClickedFunc + "; onFallStartCompleted: " + tileFallStartCompleted + "; }",parent);
				};

				//The top layer contains the interactive buttons. Tiles that are
				//indicated as border tiles are hidden using opacity so they
				//continue to take up space geometrically in the layout.
				var tile = buildTile(tileGrid);
				tile.color = (x % 2) ^ (y % 2) == 0 ? color0 : color1;
				if(tile.text == "" || tile.text == " ")
					tile.color = Qt.lighter(tile.color,borderColorLighterFactor);
				if(tile.text == " ")
					tile.opacity = 0.0;
				tile.z = 1;
				tiles.push(tile);

				//A bottom layer follows the same pattern as above except none
				//of the tiles are interactive. Even copies of the tiles from
				//the top layer are visible because they prevent colors from the
				//window background from bleeding through during animation due
				//to aliasing.
				var borderTile = buildTile(borderTileGrid);
				borderTile.text = " ";
				borderTile.color = tile.color;
				tiles.push(borderTile);
			}
		}
	}

	//Reclaculate tile size when menu size changes so tiles _appear_ to scale
	//at the same rate. Note that this scale is not linear because the tiles
	//must always be square but the menu width and height are changed
	//independently.
	onWidthChanged: {
		if(tiles.length == 0)
			return;

		tileSize = tileMenu.parent.height / 4;
		tileGrid.topPadding = -tileMenu.parent.height / 8;
	}
}

