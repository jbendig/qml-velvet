import QtQuick 2.3
import QtGraphicalEffects 1.0

Rectangle {
	readonly property variant playTime: 5000 //How long it takes for the animation to play in milliseconds.
	readonly property int playWidthChange: 60 //How much to change width by while playing.
	readonly property int playHeightChange: 200 //How much to change height by while playing.
	property color color0: "black"
	property color color1: "white"
	property variant startPlayingTime: 0

	id: tunnel

	state: ""
	states: State {
		name: "playing"
		StateChangeScript {	script: startPlayingTime = new Date().getTime(); }
		PropertyChanges { target: tunnel; restoreEntryValues: true; explicit: true; width: width + playWidthChange }
		PropertyChanges { target: tunnel; restoreEntryValues: true; explicit: true; height: height + playHeightChange }
		PropertyChanges { target: tunnel; restoreEntryValues: true; explicit: true; x: x - playWidthChange / 2 }
		PropertyChanges { target: tunnel; restoreEntryValues: true; explicit: true; y: y - playHeightChange / 2 }
		PropertyChanges { target: zoomBlur; restoreEntryValues: true; explicit: true; length: 48 }
	}

	transitions: Transition {
		PropertyAnimation { target: tunnel; properties: "x,y,width,height"; duration: state == "playing" ? playTime: 0; easing.type: Easing.InQuint }
		PropertyAnimation { target: zoomBlur; properties: "length"; duration: state == "playing" ? playTime: 0; easing.type: Easing.InQuint }
	}

	Timer {
		interval: 10
		repeat: true
		running: state == "playing"
		onTriggered: {
			var currentTime = new Date().getTime();
			shaderEffect.time = Math.min((currentTime - startPlayingTime) / playTime,1.0);
		}
	}

	ShaderEffect {
		property variant time: 0.0
		property color color0: parent.color0
		property color color1: parent.color1

		id: shaderEffect;
		anchors.fill: parent

		fragmentShader: "
			varying vec2 qt_TexCoord0;
			uniform float time; //Range is [0.0,1.0].
			uniform vec4 color0;
			uniform vec4 color1;

			static const float EPSILON = 0.00001;

			float RayPlaneIntersection(vec3 rayOrigin,vec3 rayDirection,vec3 planePosition,vec3 planeDirection)
			{
				float denominator = dot(planeDirection,rayDirection);
				if(abs(denominator) < EPSILON)
					return -1.0;

				return dot(planePosition - rayOrigin,planeDirection) / denominator;
			}

			float Vec3Attr(vec3 v,int index)
			{
				if(index == 0)
					return v.x;
				else if(index == 1)
					return v.y;
				else
					return v.z;
			}

			//How far we have moved down the tunnel.
			float TunnelPosition()
			{
				const float distance = 130.0;
				const float startOffset = 0.5;
				float t = startOffset + time * (1 - startOffset);
				return t * t * t * t * distance;
			}

			//How much the pixels should be darkened based on distance from
			//camera.
			float FogFactor(float pointDistance)
			{
				return min((1000 - time * time * time * 1000) / (pointDistance*pointDistance),1.0);
			}

			//How much to desaturate the start colors until they turn
			//monochromatic.
			float ColorBlending()
			{
				return pow(time,8);
			}

			void main() {
				//Flip screen coordinates along the y-axis because of how the
				//shader effect is interacting with the parent item which is
				//rotated 180 degrees.
				vec2 screenCoordinates = qt_TexCoord0;
				screenCoordinates.y = 1.0 - qt_TexCoord0.y;

				//Intersect a set of planes, one on each side of the viewport,
				//and find the closest intersection plane and point.
				vec3 rayOrigin = vec3(0.0,0.0,TunnelPosition());
				vec3 viewPlanePoint = rayOrigin + vec3(screenCoordinates - vec2(0.5,0.5),1.0);
				vec3 rayDirection = normalize(viewPlanePoint - rayOrigin);

				vec3 planePositions[4] = {
					vec3(0.0,-5.0,0.0), //Bottom
					vec3(0.0,5.0,0.0), //Top
					vec3(-5.0,0.0,0.0), //Left
					vec3(5.0,0.0,0.0) //Right
				};
				vec3 planeDirections[4] = {
					vec3(0.0,1.0,0.0), //Bottom
					vec3(0.0,-1.0,0.0), //Top
					vec3(1.0,0.0,0.0), //Left
					vec3(-1.0,0.0,0.0) //Right
				};
				int planePatternSamplingDimensions[8] = { //(column,row) ordered pair where (x=0,y=1,z=2)
					0,2, //Bottom
					0,2, //Top
					1,2, //Left
					1,2 //Right
				};
				float tileScale = 1.0;
				float tileOffset[8] = { //Give column and row a rediculous offset to avoid the origin modulo problem.
					500,500, //Bottom
					501,500, //Top
					501,500, //Left
					500,500, //Right
				};

				int closestPlane = -1;
				float closestPlaneDistance = 100000000000.0;
				for(int x = 0;x < 4;x++)
				{
					float t = RayPlaneIntersection(rayOrigin,rayDirection,planePositions[x],planeDirections[x]);
					if(t < EPSILON)
						continue;

					if(t < closestPlaneDistance)
					{
						closestPlane = x;
						closestPlaneDistance = t;
					}
				}

				//No plane intersected, probably the middle of the screen. Just
				//fill with the fog color.
				if(closestPlane == -1)
				{
					gl_FragColor = vec4(0.0,0.0,0.0,1.0);
					return;
				}

				vec3 rayPlaneIntersection = rayOrigin + rayDirection * closestPlaneDistance;

				//Use intersection point to compute checkerboard color.
				int column = Vec3Attr(rayPlaneIntersection,planePatternSamplingDimensions[closestPlane * 2 + 0]) * tileScale + tileOffset[closestPlane * 2 + 0];
				int row = Vec3Attr(rayPlaneIntersection,planePatternSamplingDimensions[closestPlane * 2 + 1]) * tileScale + tileOffset[closestPlane * 2 + 1];
				if(((column % 2) ^ (row % 2)) == 0)
					gl_FragColor = mix(color0,vec4(0.0,0.0,0.0,1.0),ColorBlending());
				else
					gl_FragColor = mix(color1,vec4(0.7,0.7,0.7,1.0),ColorBlending());

				//Apply fog so further away intersection points appear darker.
				gl_FragColor.xyz *= FogFactor(closestPlaneDistance);
			}"
	}

	ZoomBlur {
		id: zoomBlur
		anchors.fill: parent
		source: shaderEffect
		samples: 12
		length: 0
	}
}
