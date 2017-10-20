import QtQuick 2.3
import QtQuick.Particles 2.0

Rectangle {
	id: rect
	width: 640
	height: 480
	color: "black"

	Rectangle {
		id: wrapper
		anchors.fill: parent
		color: "#00000000"

		MenuBarButton {
			id: menuBarButton1
			text: "First"
			baseX: parent.width * 0.4
			baseY: 85
		}

		MenuBarButton {
			id: menuBarButton2
			text: "Second"
			baseX: parent.width * 0.44
			baseY: 85 + 130
		}

		MenuBarButton {
			id: menuBarButton3
			text: "Third"
			baseX: parent.width * 0.48
			baseY: 85 + 130 * 2
		}

		ParticleSystem {
			id: particles

			ItemParticle {
				delegate: Rectangle {
					property variant startRotation: Math.random() * 360
					property variant spawnTime: new Date().getTime()

					width: Math.random() * 25 + 12
					height: width
					rotation: startRotation

					Timer {
						property variant msPerRotation: 7000.0
						interval: 10
						repeat: true
						running: true
						onTriggered: {
							var nowTime = new Date().getTime();
							parent.rotation = parent.startRotation + (nowTime - parent.spawnTime) % msPerRotation / msPerRotation * 360.0;
						}
					}
				}
			}
		}

		Emitter {
			anchors.left: parent.left
			anchors.leftMargin: 15
			anchors.bottom: parent.bottom
			anchors.bottomMargin: -height
			system: particles
			width: parent.width / 6
			height: parent.height / 12
			emitRate: 10
			lifeSpan: 3000
			lifeSpanVariation: 1600
			acceleration: AngleDirection { angle: 270; magnitude: 50 }
		}
	}

	/* Debug timer and text.
	Timer {
		interval: 10
		repeat: true
		running: true
		onTriggered: {
		}
	}

	Text {
		id: debugText
		text: checkerboard.height
		z: 1
		color: "green"
	}
	*/

	Rectangle {
		id: diamondTexture
		anchors.fill: parent

		Checkerboard {
			property variant diamondWidthToHeightRatio: 0.6

			columns: 25
			rows: 25

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

	ShaderEffect {
		property variant mask: ShaderEffectSource {
			sourceItem: wrapper
			live: true
			hideSource: true
		}
		property variant source: ShaderEffectSource {
			sourceItem: diamondTexture
			hideSource: true
		}

		anchors.fill: parent
		fragmentShader: "
			varying highp vec2 qt_TexCoord0;
			uniform sampler2D mask;
			uniform sampler2D source;

			void main() {
				//Lazy multiply blending.
				gl_FragColor = texture2D(mask,qt_TexCoord0) * texture2D(source,qt_TexCoord0);
			}"
	}
}
