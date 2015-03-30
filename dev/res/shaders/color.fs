#ifdef GL_ES
precision mediump float;
#endif

const vec3 lumCoeff = vec3(0.2125, 0.7154, 0.0721);
const vec3 W = vec3(1.0, 1.0, 1.0);
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec3 A;

void main(void)
{
	vec4 texColor = texture2D(CC_Texture0, v_texCoord);
	vec3 B = vec3(texColor);

	vec3 m = step(B, vec3(0.5));
	vec3 result = mix(2.0 * A * B, W - 2.0 * ( W - A ) * ( W - B ), m);
	gl_FragColor = vec4(result, texColor.a);
	
	// vec3 result = vec3(0.0);
	// float luminance = dot(A, lumCoeff);
	// if( luminance < 0.45 ){
	// 	result = 2.0 * A * B;
	// }else if(luminance > 0.55){
	// 	result = W - 2.0 * ( W - A ) * ( W - B );
	// }else{
	// 	vec3 result1 = 2.0 * A * B;
	// 	vec3 result2 = W - 2.0 * ( W - A ) * ( W - B );
	// 	result = mix(result1, result2, ( luminance - 0.45 ) * 10.0 );
	// }
	// gl_FragColor = vec4(result, texColor.a);
}
