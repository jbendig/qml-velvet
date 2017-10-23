import QtQuick 2.3

Rectangle {
	property int columns: 10
	property int rows: 10
	property color color0: "black"
	property color color1: "white"

	ShaderEffect {
		property int columns: parent.columns
		property int rows: parent.rows
		property color color0: parent.color0
		property color color1: parent.color1

		anchors.fill: parent
		fragmentShader: "
			varying highp vec2 qt_TexCoord0;
			uniform int columns;
			uniform int rows;
			uniform vec4 color0;
			uniform vec4 color1;
			uniform lowp float qt_Opacity;

			void main() {
				int column = qt_TexCoord0.x * columns;
				int row = qt_TexCoord0.y * rows;
				if(((column % 2) ^ (row % 2)) == 0)
					gl_FragColor = color0;
				else
					gl_FragColor = color1;
			}"
	}
}
