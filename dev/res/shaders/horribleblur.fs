#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec2 u_resolution;

const float radius  = 4.;
const float samples = 2.;
const float angle=6.28/samples;

void main(void){
    vec2 PixelPos = gl_FragCoord.xy;
    
    vec3 col = vec3(0);
    
    for(float r=0.;r<radius;r++){
        for(float s=0.;s<samples;s++){
            vec2 relativepos = vec2(cos(angle*s),sin(angle*s))*r;
            col += texture2D(CC_Texture0,(PixelPos+relativepos)/u_resolution.xy).rgb;
        }
    }
    
    col /= radius*samples;
	gl_FragColor = vec4(col,1.0);
}