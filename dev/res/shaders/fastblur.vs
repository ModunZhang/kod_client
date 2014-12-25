attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

uniform float u_radius;
uniform float u_time;

varying vec4 v_fragmentColor;
varying vec2 blurCoordinates[5];

const float ani_time = 0.2;

void main() {
    gl_Position = CC_PMatrix * a_position;
    v_fragmentColor = a_color;
    float ratio = clamp((CC_Time[1] - u_time) / ani_time, 0.0, 1.0);
    vec2 singleStepOffset = vec2(u_radius, u_radius) * ratio;
	blurCoordinates[0] = a_texCoord.xy;
	blurCoordinates[1] = a_texCoord.xy + singleStepOffset * 1.407333;
	blurCoordinates[2] = a_texCoord.xy - singleStepOffset * 1.407333;
	blurCoordinates[3] = a_texCoord.xy + singleStepOffset * 3.294215;
	blurCoordinates[4] = a_texCoord.xy - singleStepOffset * 3.294215;

	// singleStepOffset.x = -singleStepOffset.x;
	// blurCoordinates[5] = a_texCoord.xy + singleStepOffset * 1.407333;
	// blurCoordinates[6] = a_texCoord.xy - singleStepOffset * 1.407333;
	// blurCoordinates[7] = a_texCoord.xy + singleStepOffset * 3.294215;
	// blurCoordinates[8] = a_texCoord.xy - singleStepOffset * 3.294215;
}

