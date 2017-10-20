import QtQuick 2.3

Rectangle {
	property int columns: 10
	property int rows: 10

	ShaderEffect {
		property int columns: parent.columns
		property int rows:  parent.rows

		anchors.fill: parent
		fragmentShader: "
			varying highp vec2 qt_TexCoord0;
			uniform int columns;
			uniform int rows;
			uniform lowp float qt_Opacity;

			void main() {
				int column = qt_TexCoord0.x * columns;
				int row = qt_TexCoord0.y * rows;
				if(((column % 2) ^ (row % 2)) == 0)
					gl_FragColor = vec4(0.66666,0.0,1.0,1.0);
				else
					gl_FragColor = vec4(0.66666,0.33333,1.0,1.0);
			}"
	}
}
