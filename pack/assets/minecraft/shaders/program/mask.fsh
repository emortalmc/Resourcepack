#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D MaskSampler;

in vec2 texCoord;
in vec2 oneTexel;

out vec4 fragColor;

void main() {
    fragColor = texture(DiffuseSampler, texCoord) * (1 - texture(MaskSampler, texCoord).a);
}