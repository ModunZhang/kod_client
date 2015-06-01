//photoshop去色黑白shader
#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main(void)
{
	vec4 texColor = texture2D(CC_Texture0, v_texCoord);
	float max_p = max(texColor.r,max(texColor.g,texColor.b));
	float min_p = min(texColor.r,min(texColor.g,texColor.b));
	float mid_p = texColor.r + texColor.g + texColor.b - max_p - min_p;
	float gray  = float(max_p - mid_p) * 0.4 + float(mid_p - min_p) * 0.4 + min_p;
	gl_FragColor = vec4(vec3(gray), texColor.a) * v_fragmentColor; 
}
