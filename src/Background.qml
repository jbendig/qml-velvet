import QtQuick 2.3

Rectangle {
	property variant cameraPos: Qt.vector3d(0.2,1.5,0.0)

	Timer {
		interval: 10
		repeat: true
		running: true
		onTriggered: {
			//Create a time curve that looks like it's breathing.
			var currentTime = new Date().getTime();
			var t = (currentTime % 15000) / 15000 * Math.PI * 2;
			shaderEffect.time = Math.sin(Math.sin(Math.sin(Math.sin(t) + 1)));
		}
	}

	ShaderEffect {
		id: shaderEffect;
		property variant time: 0.0
		property variant cameraPos: parent.cameraPos

		anchors.fill: parent
		fragmentShader: "
			varying vec2 qt_TexCoord0;
			uniform float time;
			uniform vec3 cameraPos;

			void main() {
				vec3 viewPlanePoint = cameraPos + vec3(qt_TexCoord0 - vec2(0.5,0.5),1.0);
				vec3 rayOrigin = cameraPos;
				vec3 rayDirection = normalize(viewPlanePoint - cameraPos);

				//Rotate camera just slightly because it looks more interesting.
				float rot = 0.2;
				mat2 rotationMatrix = mat2(cos(rot),sin(rot),-sin(rot),cos(rot));
				rayDirection.xz = rayDirection.xz * rotationMatrix;

				//Rays shot into the sky should appear black.
				if(rayDirection.y < 0.00001)
				{
					gl_FragColor = vec4(0.0,0.0,0.0,1.0);
					return;
				}

				//Find intersection point of ray and the floor plane.
				float t =  rayOrigin.y / rayDirection.y;
				vec3 rayGroundIntersection = rayOrigin + rayDirection * t;

				//Use a checkerboard texture for the floor plane.
				int column = rayGroundIntersection.x + 500; //Give column and row a rediculous offset to avoid the origin modulo problem.
				int row = rayGroundIntersection.z + 500;
				if(((column % 2) ^ (row % 2)) == 0)
					gl_FragColor = vec4(121.0/255.0,37.0/255.0,232.0/255.0,1.0);
				else
					gl_FragColor = vec4(83.0/255.0,87.0/255.0,222.0/255.0,1.0);

				//Apply fog so tiles near the horizon blend with the sky.
				gl_FragColor.xyz *= min((100 + time * 800) / (t * t),1.0);
			}"
	}
}
