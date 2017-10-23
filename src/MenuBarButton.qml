import QtQuick 2.3

Rectangle {
	property int baseX: 0
	property int baseY: 0
	property variant text: "Text"
	property bool showFullscreen: false //When true, menu bar button is flipped over and fills most of the parent.
	property variant flipSideChild: Rectangle {}
	signal flipSideVisibleChanged(bool visible) //Emitted at the exact moment the reverse side of the menu bar button is made visible or hidden.

	onShowFullscreenChanged:  {
		if(showFullscreen)
		{
			animationTimer.running = false;
			floatTransition.enabled = false;
			floatVerticalAnimation.paused = true;
			fullscreenShowTransition.enabled = true;
			pivotZAnimation.paused = false;
			state = "fullscreen";
		}
		else
		{
			fullscreenShowTransition.enabled = false;
			fullscreenHideTransition.enabled = true;
			pivotZAnimation.paused = true;
			state = "";
		}
	}
	onFlipSideChildChanged: flipSideChild.parent = flipSide

	id: menuItem
	x: baseX
	y: baseY
	width: 6 * parent.width / 4
	height: parent.height / 3
	antialiasing: true
	state: "float"
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

	Rectangle {
		id: flipSide
		color: "green" //Debug color to make it obvious when flipSideChild is not set.
		anchors.left: parent.left
		anchors.top: parent.top
		width: parent.width
		height: parent.height
		z: 1
		enabled: false
		opacity: 0.0

		//Apply transform to reverse the transform performed on parent so flipSide doesn't appear upside down.
		transform: [
			Rotation {
				id: flipSideRotationX
				origin.x: menuItem.width / 2
				origin.y: menuItem.height / 2
				axis.x: 1.0
				axis.y: 0.0
				axis.z: 0.0
				angle: 180
			}
		]
	}

	//Float up and down.
	SequentialAnimation on y {
		id: floatVerticalAnimation
		loops: Animation.Infinite
		PropertyAnimation { duration: 2000; to: menuItem.baseY + Math.random() * 10 * (Math.random() > 0.5 ? 1 : -1); easing.type: Easing.Linear }
		PropertyAnimation { duration: 2000; to: menuItem.baseY + Math.random() * 10 * (Math.random() > 0.5 ? 1 : -1); easing.type: Easing.Linear }
	}

	//Pivot slightly and slowly along the Z-axis.
	SequentialAnimation on rotation {
		id: pivotZAnimation
		loops: Animation.Infinite
		PropertyAnimation { duration: 4000; to: -1; easing.type: Easing.Linear }
		PropertyAnimation { duration: 4000; to: 1; easing.type: Easing.Linear }
		onStarted: {
			paused = true
		}
	}

	//Rotate on the x and y axis slightly while floating.
	Timer {
		id: animationTimer
		interval: 1500
		repeat: true
		running: true
		onTriggered: {
			if(parent.state != "fullscreen")
			{
				//Force state to generate new rotation angles.
				parent.state = ""
				parent.state = "float";
			}
		}
	}

	states: [
		State {
			name: "float"
			PropertyChanges { target: rotationX; restoreEntryValues: true; explicit: true; angle: -65 + (0.1 + Math.random() * 2) * (Math.random() > 0.5 ? 1 : -1); }
			PropertyChanges { target: rotationZ; restoreEntryValues: true; explicit: true; angle: 15 + (0.1 + Math.random() * 2) * (Math.random() > 0.5 ? 1 : -1); }
		},
		State {
			name: "fullscreen"
			PropertyChanges { target: menuItem; restoreEntryValues: true; explicit: true; x: -10; }
			PropertyChanges { target: menuItem; restoreEntryValues: true; explicit: true; y: parent.height * (1 - 0.833) / 2; }
			PropertyChanges { target: menuItem; restoreEntryValues: true; explicit: true; height: parent.height * 0.833; }
			PropertyChanges { target: menuItem; restoreEntryValues: true; explicit: true; width: parent.width * 1.2; }
			PropertyChanges { target: rotationX; restoreEntryValues: true; explicit: true; angle: -180; }
			PropertyChanges { target: rotationY; restoreEntryValues: true; explicit: true; angle: 0; }
			PropertyChanges { target: rotationZ; restoreEntryValues: true; explicit: true; angle: 0; }
		}
	]

	transitions: [
		Transition {
			id: floatTransition
			PropertyAnimation { target: menuItem; properties: "x,y,width,height"; duration: 1500; easing.type: Easing.OutQuad }
			PropertyAnimation { target: rotationX; properties: "angle"; duration: 1500; easing.type: Easing.OutQuad }
			PropertyAnimation { target: rotationZ; properties: "angle"; duration: 1500; easing.type: Easing.OutQuad }
		},
		Transition {
			id: fullscreenShowTransition
			enabled: false
			PropertyAnimation { target: menuItem; properties: "x,y,width,height"; duration: 1500; easing.type: Easing.OutQuad }
			PropertyAnimation { target: rotationY; properties: "angle"; duration: 1500; easing.type: Easing.OutQuad }
			PropertyAnimation { target: rotationZ; properties: "angle"; duration: 1500; easing.type: Easing.OutQuad }
			SequentialAnimation {
				PropertyAnimation { target: rotationX; properties: "angle"; to: -90; duration: 250; easing.type: Easing.Linear }
				ScriptAction {
					script: {
						flipSide.opacity = 1.0;
						flipSide.enabled = true;
						flipSideVisibleChanged(menuItem.showFullscreen);
					}
				}
				PropertyAnimation { target: rotationX; properties: "angle"; from: -90; to: -180; duration: 250 * 3.6; easing.type: Easing.Linear }
			}
		},
		//Setup separate transition for hiding fullscreen mode because the
		//flipSideVisibleChanged signal must be emitted at the exact moment
		//before the flip side is hidden. The float transition is resumed
		//immediately after the transition completes.
		Transition {
			id: fullscreenHideTransition
			enabled: false
			PropertyAnimation { target: menuItem; properties: "x,y,width,height"; duration: 1500; easing.type: Easing.OutQuad }
			PropertyAnimation { target: rotationY; properties: "angle"; duration: 1500; easing.type: Easing.OutQuad }
			PropertyAnimation { target: rotationZ; properties: "angle"; duration: 1500; easing.type: Easing.OutQuad }
			SequentialAnimation {
				PropertyAnimation { target: rotationX; properties: "angle"; from: -180; to: -90; duration: 250 * 3.6; easing.type: Easing.Linear }
				ScriptAction {
					script: {
						flipSide.opacity = 0.0;
						flipSide.enabled = false;
						flipSideVisibleChanged(menuItem.showFullscreen);
					}
				}
				PropertyAnimation { target: rotationX; properties: "angle"; to: -65; duration: 250; easing.type: Easing.Linear }
				ScriptAction {
					script: {
						fullscreenHideTransition.enabled = false;
						floatTransition.enabled = true;
						floatVerticalAnimation.paused = false;
						animationTimer.running = true;
					}
				}
			}
		}
	]

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onEntered: menuItem.color = "#FFAEAE";
		onExited: menuItem.color = "#FFFFFF";
		onClicked: parent.showFullscreen = !parent.showFullscreen
	}
}
