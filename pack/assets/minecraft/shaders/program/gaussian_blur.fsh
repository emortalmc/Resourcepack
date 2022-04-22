#version 150

uniform sampler2D DiffuseSampler;

in vec2 texCoord;
in vec2 oneTexel;

uniform vec2 InSize;
uniform vec2 BlurDir;

out vec4 fragColor;

void main() {
    const int radius = 30;
    const float kernel[radius*2+1] = float[radius*2+1](0.004170710007256603, 0.004693066875886336, 0.005259764673373045, 0.005871359960660599, 0.006527906449106977, 0.007228895706727251, 0.007973202941950822, 0.008759039798055557, 0.009583916096982873, 0.010444612412437323, 0.011337165224497913, 0.012256866209291195, 0.013198276948221413, 0.014155260005426397, 0.015121026926227722, 0.01608820326312498, 0.01704891025196872, 0.01799486225447687, 0.018917478571399433, 0.019808007731938543, 0.020657661898691133, 0.02145775861241461, 0.022199866755291852, 0.02287595335115444, 0.023478527659658063, 0.024000778968602723, 0.024436704550346112, 0.024781224426041235, 0.025030279872073218, 0.02518091299878669, 0.025231325220201602, 0.02518091299878669, 0.025030279872073218, 0.024781224426041235, 0.024436704550346112, 0.024000778968602723, 0.023478527659658063, 0.02287595335115444, 0.022199866755291852, 0.02145775861241461, 0.020657661898691133, 0.019808007731938543, 0.018917478571399433, 0.01799486225447687, 0.01704891025196872, 0.01608820326312498, 0.015121026926227722, 0.014155260005426397, 0.013198276948221413, 0.012256866209291195, 0.011337165224497913, 0.010444612412437323, 0.009583916096982873, 0.008759039798055557, 0.007973202941950822, 0.007228895706727251, 0.006527906449106977, 0.005871359960660599, 0.005259764673373045, 0.004693066875886336, 0.004170710007256603);

    vec4 blurred = vec4(0.0);
    for (int i=-radius; i<=radius; i++) {
        vec4 sampleValue = texture(DiffuseSampler, texCoord + oneTexel * i * BlurDir * 2);
        blurred = blurred + sampleValue * kernel[i+radius];
    }

    fragColor = vec4(blurred.rgb / (blurred.a*0.8+0.2), blurred.a);
}