import QtQuick 2.6

Rectangle {
	property variant tiles: []

	function resetTiles() {
		for(var x = 0;x < tiles.length;x++)
		{
			var tile = tiles[x];
			tile.reset();
		}
	}

	id: tileMenu
	anchors.fill: parent

	//Checkerboard item to help cleanly calculate the tile button sizes. This
	//is a temporary hack that'll probably be removed...
	Checkerboard {
		columns: 11
		rows: 11

		id: checkerboard
		visible: false
		anchors.centerIn: parent
		width: (parent.width > parent.height ? parent.width : parent.height) * Math.sqrt(2)
		height: checkerboard.width
	}

	Grid {
		id: tileGrid
		rows: 3
		columns: 6
		anchors.fill: parent
		leftPadding: 38
		topPadding: 52
	}

	Component.onCompleted: {
		var refText = [
			"","1","2","3","4","5","","6","7","8","9","10","Back","11","12","13","14","15"
		];
		var index = 0;
		var tileButtonComponent = Qt.createComponent("TileButton.qml");
		for(var y = 0;y < tileGrid.rows;y++)
		{
			for(var x = 0;x < tileGrid.columns;x++,index++)
			{
				var tileText = refText[index];
				var tileClickedFunc = tileText == "Back" ? "function() { menuBarButton2.showFullscreen = false; }" : "function() { z = 2; this.fallStart(); }";
				var tileFallStartCompleted = "function() { for(var x = 0;x < tileMenu.tiles.length;x++) { var tile = tileMenu.tiles[x]; if(tile == this) continue; tile.fallFollow(this); } }";
				var tile = Qt.createQmlObject("import QtQuick 2.3; TileButton { text: \"" + tileText + "\"; onClicked: " + tileClickedFunc + "; onFallStartCompleted: " + tileFallStartCompleted + "; }",tileGrid);
				tile.color = (x % 2) ^ (y % 2) == 0 ? "red" : "blue";
				tile.z = 1;
				tiles.push(tile);
			}
		}
	}

	//Recalculate tile sizes whenever the menu width changes since they are
	//related (indirectly using Checkerboard item above).
	onWidthChanged: {
		if(tiles.length == 0)
			return;

		for(var x = 0;x < tiles.length;x++)
		{
			var tile = tiles[x];
			tile.width = checkerboard.getTileWidth();
			tile.height = checkerboard.getTileHeight();
		}
	}
}

