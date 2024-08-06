#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform vec2 ScreenSize;
uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;

out vec4 fragColor;

bool same(float a, float b, float epsilon) {
    return abs(a-b) < epsilon;
}

vec4 colormap(float x) {
    return vec4(1, mix(0.7, 0.0, x + 0.15), mix(0, 1, x + 0.15), 1.0);
}

float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u*u*(3.0-2.0*u);

    float res = mix(
    mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
    mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
    return res*res;
}

const mat2 mtx = mat2( 0.80,  0.60, -0.60,  0.80 );

float fbm( vec2 p ) {
    float iTime = GameTime * 2000.0;
    float f = 0.0;

    f += 0.500000*noise( p + iTime  ); p = mtx*p*2.02;
    f += 0.031250*noise( p ); p = mtx*p*2.01;
    f += 0.250000*noise( p ); p = mtx*p*2.03;
    f += 0.125000*noise( p ); p = mtx*p*2.01;
    f += 0.062500*noise( p ); p = mtx*p*2.04;
    f += 0.015625*noise( p + sin(iTime) );

    return f/0.96875;
}

float pattern( in vec2 p ) {
    return fbm( p + fbm( p + fbm( p ) ) );
}


void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }

    vec4 texColor = texture(Sampler0, texCoord0);

    // Emortal Cube: rgb(40, 36, 37)
    if (same(40.0/255.0, texColor.r, 0.0001) && same(36.0/255.0, texColor.g, 0.0001) && same(37.0/255.0, texColor.b, 0.0001)) {
        // Pixelate
        int res = 128;
        vec2 pixelTex = texCoord0;
        pixelTex.y *= 0.5;
        pixelTex *= res * 10;
        pixelTex = floor(pixelTex);
        pixelTex /= res * 10;

        vec2 uv = (pixelTex) * 40;
        float shade = pattern(uv);
        color = vec4(colormap(shade).rgb, 1.0);
        color.a = 1.0;
        color.rgb *= 1 - (vertexColor.rgb * 0.5);
    }

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
