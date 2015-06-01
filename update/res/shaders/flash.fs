#ifdef GL_ES
precision highp float;
#endif

varying vec2 v_texCoord;
uniform float ratio;
const float MAX_ = .4;
void main(void)
{
    vec4 col = texture2D(CC_Texture0, v_texCoord);
    float mid = step(0.5, ratio);
    float r = smoothstep(0.0, 1.0, ratio * (1.0 - mid) / 0.5) * (1.0 - mid) + smoothstep(0.0, 1.0, (1.0 - ratio) * mid / 0.5) * mid;
    gl_FragColor = vec4(col.rgb * (r * MAX_ + 1.0) , col.a) ;
}