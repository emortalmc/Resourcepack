#version 150

uniform sampler2D DiffuseSampler;

in vec2 texCoord;
in vec2 oneTexel;

uniform vec2 InSize;
uniform vec2 ExpandDir;

out vec4 fragColor;

void main() {
    const int radius = 10;

    vec4 colour = vec4(0.0);
    for (int i=-radius; i<=radius; i++) {
        vec4 sampleValue = texture(DiffuseSampler, texCoord + oneTexel * i * ExpandDir * 2);

        float alpha = sampleValue.a;
        colour = colour.rgba * (1 - alpha) + sampleValue.rgba * alpha;
    }

    fragColor = colour;
}