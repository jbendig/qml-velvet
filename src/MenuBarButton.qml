import QtQuick 2.3

Rectangle {
	property int baseX: 0
	property int baseY: 0
	property variant text: "Text"

	id: menuItem
	x: baseX
	y: baseY
	width: 6 * parent.width / 4
	height: parent.height / 3
	antialiasing: true
	transform: [
		//Rotate slightly to look elongated and make the top half of the text
		//larger. Note: The order of these rotations matter!
		Rotation {
			id: rotationZ
			origin.x: menuItem.width / 2
			origin.y: menuItem.height / 2
			axis.z: 1.0
			angle: 15
		},
		Rotation {
			id: rotationX
			origin.x: menuItem.width / 2
			origin.y: menuItem.height / 2
			axis.x: 1.0
			axis.y: 0.0
			axis.z: 0.0
			angle: -65
		},
		Rotation {
			id: rotationY
			origin.x: menuItem.width / 2
			origin.y: menuItem.height / 2
			axis.x: 0.0
			axis.y: 1.0
			axis.z: 0.0
			angle: 25
		}
	]

	Text {
		color: "black"
		text: menuItem.text
		font.pointSize: 75
		font.letterSpacing: -5
		anchors.left: parent.left
		anchors.top: parent.top
		width: parent.width
		height: parent.height
	}

	//Float up and down.
	SequentialAnimation on y {
		loops: Animation.Infinite
		PropertyAnimation { duration: 2000; to: menuItem.baseY + Math.random() * 10 * (Math.random() > 0.5 ? 1 : -1); easing.type: Easing.Linear }
		PropertyAnimation { duration: 2000; to: menuItem.baseY + Math.random() * 10 * (Math.random() > 0.5 ? 1 : -1); easing.type: Easing.Linear }
	}

	//Rotate on the x and y axis slightly while floating.
	Timer {
		interval: 1500
		repeat: true
		running: true
		onTriggered: {
			parent.state = ""
			parent.state = "float-1";
		}
	}

	states: [
		State {
			name: "float-1"
			PropertyChanges { target: rotationX; restoreEntryValues: true; explicit: true; angle: -65 + (0.1 + Math.random() * 2) * (Math.random() > 0.5 ? 1 : -1); }
			PropertyChanges { target: rotationZ; restoreEntryValues: true; explicit: true; angle: 15 + (0.1 + Math.random() * 2) * (Math.random() > 0.5 ? 1 : -1); }
		}
	]

	transitions: Transition {
		PropertyAnimation { target: rotationX; properties: "angle"; duration: 1500; easing.type: Easing.OutQuad }
		PropertyAnimation { target: rotationZ; properties: "angle"; duration: 1500; easing.type: Easing.OutQuad }
	}

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onEntered: menuItem.color = "#FFAEAE";
		onExited: menuItem.color = "#FFFFFF";
	}
}
