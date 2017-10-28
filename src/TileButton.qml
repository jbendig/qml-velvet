import QtQuick 2.3

Rectangle {
	property string text: ""
	property int textSize: 24
	property variant _fallFollowOffsetX: 0
	property variant _fallFollowDifference: 0
	signal clicked
	signal fallStartCompleted

	function fallStart() {
		fallStartTransition.enabled = true;
		state = "fall-start";
	}

	function fallFollow(fallStartTile) {
		_fallFollowOffsetX = (centerX(tileButton) - fallStartTile.x) * 0.8;
		_fallFollowDifference = hypot(fallStartTile.x - centerX(tileButton),
		                              fallStartTile.x + fallStartTile.height - centerY(tileButton));

		fallFollowTransition.enabled = true;
		state = "fall-follow";
	}

	function reset() {
		fallStartTransition.enabled = false;
		fallFollowTransition.enabled = false;
		_fallFollowOffsetX = 0;
		_fallFollowDifference = 0;
		state = "";
		textItem.state = "";
	}

	function centerX(item) {
		return item.x + item.width / 2;
	}

	function centerY(item) {
		return item.y + item.height / 2;
	}

	function hypot(x,y) {
		//QML as of Qt 5.7 doesn't have Math.hypot. :/
		return Math.sqrt(x * x + y * y);
	}

	id: tileButton

	Text {
		property int textSize: tileButton.textSize
		readonly property variant textSizeRelativeScaleFactor: 1/96.0 //How much to scale textSize relative to tile width. Used to make text scale with the button's size.

		id: textItem
		text: parent.text
		anchors.centerIn: parent
		color: "black"
		font.pointSize: tileButton.width * textSizeRelativeScaleFactor * textSize + 1.0

		states: [
			State {
				name: "hover"
				PropertyChanges { target: textItem; restoreEntryValues: true; explicit: true; font.pointSize: font.pointSize * 1.5 }
			}
		]

		transitions: [
			Transition {
				PropertyAnimation { target: textItem; properties: "font.pointSize"; duration: 250; easing.type: Easing.InOutQuad }
			}
		]
	}

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: true
		onEntered: {
			if(text != "" && tileButton.state == "")
			{
				tileButton.state = "hover";
				textItem.state = "hover";
			}
		}
		onExited: {
			if(tileButton.state == "hover")
			{
				tileButton.state = "";
				textItem.state = "";
			}
		}
		onClicked: {
			if(text != "")
				parent.clicked()
		}
	}

	transform: [
		Rotation {
			id: rotationZ
			origin.x: 0 //Pivot rotation around the bottom left corner.
			origin.y: tileButton.height
			axis.z: 1.0
			angle: 0
		},
		Translate {
			id: translate
			x: 0
			y: 0
		}
	]

	states: [
		State {
			name: "fall-start"
			PropertyChanges { target: rotationZ; restoreEntryValues: true; explicit: true; angle : 135 }
			PropertyChanges { target: translate; restoreEntryValues: true; explicit: true; y: 640 }
			PropertyChanges { target: tileButton; restoreEntryValues: true; explicit: true; opacity: 0.0; z: 2 }
		},
		State {
			name: "fall-follow"
			PropertyChanges { target: rotationZ; restoreEntryValues: true; explicit: true; angle : _fallFollowOffsetX * 0.05 }
			PropertyChanges { target: translate; restoreEntryValues: true; explicit: true; x: _fallFollowOffsetX }
			PropertyChanges { target: translate; restoreEntryValues: true; explicit: true; y: 640 }
			PropertyChanges { target: tileButton; restoreEntryValues: true; explicit: true; opacity: 0.0; z: 1 + 1 / _fallFollowDifference }
		},
		State {
			name: "hover"
			PropertyChanges { target: tileButton; restoreEntryValues: true; explicit: true; color: Qt.lighter(tileButton.color,1.1) }
		}
	]

	transitions: [
		Transition {
			id: fallStartTransition
			enabled: false
			SequentialAnimation {
				PropertyAnimation { target: rotationZ; properties: "angle"; duration: 1000; easing.type: Easing.OutElastic }
				PropertyAnimation { target: translate; properties: "y"; duration: 250; easing.type: Easing.Linear }
				ScriptAction { script: fallStartCompleted(); }
				PropertyAnimation { target: translate; properties: "y"; duration: 750; easing.type: Easing.Linear }

				//Hide tile after it falls off the screen so it doesn't flip into view during MenuBarButton flip animation.
				PropertyAnimation { target: tileButton; properties: "opacity"; to: 0.0; duration: 0; easing.type: Easing.Linear } 
			}
		},
		Transition {
			id: fallFollowTransition
			enabled: false
			SequentialAnimation {
				ParallelAnimation {
					PropertyAnimation { target: rotationZ; properties: "angle"; duration: 1.5 * _fallFollowDifference; easing.type: Easing.Linear }
					PropertyAnimation { target: translate; properties: "x"; duration: 1.5 * _fallFollowDifference; easing.type: Easing.InQuint }
					PropertyAnimation { target: translate; properties: "y"; duration: 1.5 * _fallFollowDifference; easing.type: Easing.InQuint }
					PropertyAnimation { target: tileButton; properties: "z"; duration: 0; }
				}

				//See fallStartTransition above for explanation.
				PropertyAnimation { target: tileButton; properties: "opacity"; to: 0.0; duration: 0; easing.type: Easing.Linear } 
			}
		}
	]
}

