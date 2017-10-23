import QtQuick 2.3

Rectangle {
	anchors.fill: parent

	Checkerboard {
		property variant diamondWidthToHeightRatio: 0.6

		columns: 25
		rows: 25
		color0: Qt.rgba(0.66666,0.0,1.0,1.0)
		color1: Qt.rgba(0.66666,0.33333,1.0,1.0)

		id: checkerboard
		anchors.centerIn: parent
		width: (parent.width > parent.height ? parent.width : parent.height) * Math.sqrt(2) * (1/diamondWidthToHeightRatio)
		height: checkerboard.width
		transform: [
			Rotation {
				id: checkerboardRotation
				origin.x: checkerboard.width / 2
				origin.y: checkerboard.height / 2
				axis { x: 0.0; y: 0.0; z: 1.0 }
				angle: 45
			},
			Scale {
				xScale: checkerboard.diamondWidthToHeightRatio
				origin.x: checkerboard.width / 2
				origin.y: checkerboard.height / 2
			}
		]
	}
} 
