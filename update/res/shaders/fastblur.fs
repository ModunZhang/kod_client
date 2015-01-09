#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform float u_radius;
uniform float u_time;

varying vec2 blurCoordinates[13];

#define ROUND0 0.2
#define ROUND1 0.6
#define ROUND2 0.15
#define ROUND3 0.05

#define U_ROUND1 (ROUND1 * 0.25)
#define U_ROUND2 (ROUND2 * 0.25)
#define U_ROUND3 (ROUND3 * 0.25)

void main() {
    vec4 sum = vec4(0.0);
    sum += texture2D(CC_Texture0, blurCoordinates[0]) * ROUND0;

    sum += texture2D(CC_Texture0, blurCoordinates[1]) * U_ROUND1;
    sum += texture2D(CC_Texture0, blurCoordinates[2]) * U_ROUND1;
    sum += texture2D(CC_Texture0, blurCoordinates[3]) * U_ROUND1;
    sum += texture2D(CC_Texture0, blurCoordinates[4]) * U_ROUND1;

    sum += texture2D(CC_Texture0, blurCoordinates[5]) * U_ROUND2;
    sum += texture2D(CC_Texture0, blurCoordinates[6]) * U_ROUND2;
    sum += texture2D(CC_Texture0, blurCoordinates[7]) * U_ROUND2;
    sum += texture2D(CC_Texture0, blurCoordinates[8]) * U_ROUND2;

    sum += texture2D(CC_Texture0, blurCoordinates[9]) * U_ROUND3;
    sum += texture2D(CC_Texture0, blurCoordinates[10]) * U_ROUND3;
    sum += texture2D(CC_Texture0, blurCoordinates[11]) * U_ROUND3;
    sum += texture2D(CC_Texture0, blurCoordinates[12]) * U_ROUND3;

    gl_FragColor = v_fragmentColor * sum;
}
