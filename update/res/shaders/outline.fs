
varying vec2 v_texCoord;
uniform vec2 iResolution;
// float d = sin(CC_Time[1] * 5.0)*0.5 + 1.5; // kernel offset
float d = 1.0;
float lookup(vec2 p, float dx, float dy)
{
    vec2 uv = (vec2(p.x, iResolution.y - p.y) + vec2(dx * d, dy * d)) / iResolution.xy;
    vec4 c = texture2D(CC_Texture0, uv.xy);
	
	// return as luma
    // return 0.8193*c.r + 0.7152*c.g + 0.0722*c.b;
    return 0.2126*c.r + 0.7152*c.g + 0.0722*c.b;
}

void main(void)
{
    vec2 p = gl_FragCoord.xy;
    
	// simple sobel edge detection
    float gx = 0.0;
    gx += -1.0 * lookup(p, -1.0, -1.0);
    gx += -2.0 * lookup(p, -1.0,  0.0);
    gx += -1.0 * lookup(p, -1.0,  1.0);
    gx +=  1.0 * lookup(p,  1.0, -1.0);
    gx +=  2.0 * lookup(p,  1.0,  0.0);
    gx +=  1.0 * lookup(p,  1.0,  1.0);
    
    float gy = 0.0;
    gy += -1.0 * lookup(p, -1.0, -1.0);
    gy += -2.0 * lookup(p,  0.0, -1.0);
    gy += -1.0 * lookup(p,  1.0, -1.0);
    gy +=  1.0 * lookup(p, -1.0,  1.0);
    gy +=  2.0 * lookup(p,  0.0,  1.0);
    gy +=  1.0 * lookup(p,  1.0,  1.0);
    
	// hack: use g^2 to conceal noise in the video
    float g = gx*gx + gy*gy;
    // float g2 = g * (sin(CC_Time[1]) / 2.0 + 0.5);
    
    // vec4 col = texture2D(CC_Texture0, vec2(gl_FragCoord.x, iResolution.y - gl_FragCoord.y) / iResolution.xy);
    // vec4 col = texture2D(CC_Texture0, v_texCoord);
    vec4 col = vec4(0.0);
    col += vec4(0.0, g, 0.0, 1.0);
    
    gl_FragColor = col;
}