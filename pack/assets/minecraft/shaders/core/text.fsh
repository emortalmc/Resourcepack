#version 330

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
#moj_import <minecraft:fog.glsl>
#endif

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:globals.glsl>

uniform sampler2D Sampler0;

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
in float sphericalVertexDistance;
in float cylindricalVertexDistance;
#endif

in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

const vec3 WIPE_LEFT_COLOR = vec3(100.0f, 36.0f, 44.0f) / 255.0f;
const vec3 WIPE_RIGHT_COLOR = vec3(100.0f, 36.0f, 48.0f) / 255.0f;
const vec3 DISCARD_COLOR = vec3(1.0f, 1.0f, 1.0f) / 255.0f;

float easeOut(float x) {
    return x;
}

bool similarFloat(float a, float b) {
    return abs(a - b) < 0.001;
}

bool similar(vec4 a, vec3 b) {
    return similarFloat(a.x, b.x) && similarFloat(a.y, b.y) && similarFloat(a.z, b.z);
}
bool similarShadow(vec4 a, vec3 b) {
    b = b * 0.25;
    return similarFloat(a.x, b.x) && similarFloat(a.y, b.y) && similarFloat(a.z, b.z);
}

void wipe(vec2 uv, float wipe) {
    float wipeAmount = uv.x + uv.y;
    if (wipeAmount > 2.0 * wipe) {
        discard;
    }
}

void main() {
#ifdef IS_GRAYSCALE
    vec4 texCol = texture(Sampler0, texCoord0).rrrr;
#else
    vec4 texCol = texture(Sampler0, texCoord0);
#endif
    vec4 color = texCol * vertexColor * ColorModulator;
    vec2 uv = gl_FragCoord.xy / ScreenSize.xy;

    fragColor = texCol;

    if (similar(vertexColor, DISCARD_COLOR)) {
        discard;
    }

    if (similar(vertexColor, WIPE_LEFT_COLOR)) {
        float wipeFrac = easeOut(vertexColor.a);
        wipe(uv, wipeFrac);
        return;
    } else if (similarShadow(vertexColor, WIPE_LEFT_COLOR)) {
        float wipeFrac = easeOut(vertexColor.a);
        fragColor = vec4((texCol * 0.25).xyz, texCol.a);
        wipe(uv, wipeFrac);
        return;
    }

    else if (similar(vertexColor, WIPE_RIGHT_COLOR)) {
        float wipeFrac = easeOut(vertexColor.a);
        uv.x = 1 - uv.x;
        uv.y = 1 - uv.y;
        wipe(uv, wipeFrac);
        return;
    } else if (similarShadow(vertexColor, WIPE_RIGHT_COLOR)) {
        float wipeFrac = easeOut(vertexColor.a);
        fragColor = vec4((texCol * 0.25).xyz, texCol.a);
        uv.x = 1 - uv.x;
        uv.y = 1 - uv.y;
        wipe(uv, wipeFrac);
        return;
    }

    if (color.a < 0.1) {
        discard;
    }

#ifdef IS_SEE_THROUGH
    fragColor = color * ColorModulator;
#elif defined(IS_GUI)
    fragColor = color;
#else
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
#endif

}