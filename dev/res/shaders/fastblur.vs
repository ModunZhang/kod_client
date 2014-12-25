attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

uniform float u_radius;
uniform float u_time;

varying vec4 v_fragmentColor;
// 上限是14
varying vec2 blurCoordinates[13];

const float ani_time = 1.0;

#define ROUND1 1.0
#define ROUND2 3.0
#define ROUND3 5.0

void main() {
    gl_Position = CC_PMatrix * a_position;
    v_fragmentColor = a_color;
    float ratio = clamp((CC_Time[1] - u_time) / ani_time, 0.0, 1.0);
    vec2 singleStepOffset = vec2(u_radius, u_radius) * ratio;
    vec2 NegeteStepOffset = vec2(singleStepOffset.x, -singleStepOffset.y);
    vec2 coordXStepOffset = vec2(singleStepOffset.x, 0);
    vec2 coordYStepOffset = vec2(0, singleStepOffset.y);

	blurCoordinates[0] = a_texCoord.xy;

	blurCoordinates[1] = a_texCoord.xy + coordXStepOffset * ROUND1;
	blurCoordinates[2] = a_texCoord.xy - coordXStepOffset * ROUND1;
	blurCoordinates[3] = a_texCoord.xy + coordYStepOffset * ROUND1;
	blurCoordinates[4] = a_texCoord.xy - coordYStepOffset * ROUND1;

	blurCoordinates[5] = a_texCoord.xy + singleStepOffset * ROUND2;
	blurCoordinates[6] = a_texCoord.xy - singleStepOffset * ROUND2;
	blurCoordinates[7] = a_texCoord.xy + NegeteStepOffset * ROUND2;
	blurCoordinates[8] = a_texCoord.xy - NegeteStepOffset * ROUND2;

	blurCoordinates[9] = a_texCoord.xy + coordXStepOffset * ROUND3;
	blurCoordinates[10] = a_texCoord.xy - coordXStepOffset * ROUND3;
	blurCoordinates[11] = a_texCoord.xy + coordYStepOffset * ROUND3;
	blurCoordinates[12] = a_texCoord.xy - coordYStepOffset * ROUND3;
}

