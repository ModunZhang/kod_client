#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform float u_radius;
uniform float u_time;

varying vec2 blurCoordinates[5];

void main() {
    vec4 sum = vec4(0.0);
    sum += texture2D(CC_Texture0, blurCoordinates[0]) * 0.204164;
    sum += texture2D(CC_Texture0, blurCoordinates[1]) * 0.304005;
    sum += texture2D(CC_Texture0, blurCoordinates[2]) * 0.304005;
    sum += texture2D(CC_Texture0, blurCoordinates[3]) * 0.093913;
    sum += texture2D(CC_Texture0, blurCoordinates[4]) * 0.093913;
    // sum += texture2D(CC_Texture0, blurCoordinates[5]) * 0.304005;
    // sum += texture2D(CC_Texture0, blurCoordinates[6]) * 0.304005;
    // sum += texture2D(CC_Texture0, blurCoordinates[7]) * 0.093913;
    // sum += texture2D(CC_Texture0, blurCoordinates[8]) * 0.093913;


    gl_FragColor = v_fragmentColor * sum;
}
