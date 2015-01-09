#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec2 resolution;
uniform float blurRadius;
uniform float sampleNum;
uniform float time;
const float ani_time = 0.2;

vec4 blur(vec2 p)
{
    float cur_time = CC_Time[1];
    float ratio = clamp((cur_time - time) / ani_time, 0.0, 1.0);
    float cur_sampleNum = sampleNum * ratio;
    float cur_blurRadius = blurRadius * ratio;
    if (cur_blurRadius > 0.0 && cur_sampleNum > 1.0)
    {
        vec4 col = vec4(0.0);
        vec2 unit = 1.0 / resolution.xy;
        
        float r = cur_blurRadius;
        float sampleStep = r / cur_sampleNum;
        
        float count = 0.0;
        
        for(float x = -r; x < r; x += sampleStep)
        {
            for(float y = -r; y < r; y += sampleStep)
            {
                float weight = (r - abs(x)) * (r - abs(y));
                col += texture2D(CC_Texture0, p + vec2(x * unit.x, y * unit.y)) * weight;
                count += weight;
            }
        }
        return col / count;
    }
    return texture2D(CC_Texture0, p);
}

void main(void)
{
	vec4 col = blur(v_texCoord);
	gl_FragColor = col * v_fragmentColor;
}


