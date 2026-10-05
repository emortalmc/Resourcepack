#version 330
#extension GL_ARB_separate_shader_objects : require

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
#include <minecraft:fog.glsl>
#endif

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:globals.glsl>
#include <minecraft:oit.glsl>

uniform sampler2D Sampler0;

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

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;
#endif

layout(location = 2) in vec4 vertexColor;
layout(location = 3) in vec2 texCoord0;

#ifndef OIT_ALPHA_ONLY
layout(location = 0) out vec4 fragColor;
#endif

vec4 calculateFinalColor(vec4 color) {
    #ifdef OIT_ACCUMULATE
    color = sampleColorForAccumulation(color);
    #endif

    #if !defined(IS_SEE_THROUGH) && !defined(IS_GUI)

    #ifdef OIT_ACCUMULATE
    vec4 fogColor = vec4(FogColor.rgb * color.a, FogColor.a);
    #else
    vec4 fogColor = FogColor;
    #endif

    color = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, fogColor);
    #endif

    return color;
}

void main() {
    #ifdef IS_GRAYSCALE
    vec4 texColor = texture(Sampler0, texCoord0).rrrr;
    #else
    vec4 texColor = texture(Sampler0, texCoord0);
    #endif

    vec4 color = texColor * vertexColor * ColorModulator;

    vec2 uv = gl_FragCoord.xy / ScreenSize.xy;

#ifndef OIT_ALPHA_ONLY
    if (similar(vertexColor, DISCARD_COLOR)) {
        discard;
    }

    if (similar(vertexColor, WIPE_LEFT_COLOR)) {
        wipe(uv, easeOut(vertexColor.a));
        if (texColor.a < 0.1) discard;
        fragColor = vec4(texColor.rgb, texColor.a) * ColorModulator;
        return;
    } else if (similarShadow(vertexColor, WIPE_LEFT_COLOR)) {
        wipe(uv, easeOut(vertexColor.a));
        if (texColor.a < 0.1) discard;
        fragColor = vec4(texColor.rgb * 0.25, texColor.a) * ColorModulator;
        return;
    } else if (similar(vertexColor, WIPE_RIGHT_COLOR)) {
        uv = 1.0 - uv;
        wipe(uv, easeOut(vertexColor.a));
        if (texColor.a < 0.1) discard;
        fragColor = vec4(texColor.rgb, texColor.a) * ColorModulator;
        return;
    } else if (similarShadow(vertexColor, WIPE_RIGHT_COLOR)) {
        uv = 1.0 - uv;
        wipe(uv, easeOut(vertexColor.a));
        if (texColor.a < 0.1) discard;
        fragColor = vec4(texColor.rgb * 0.25, texColor.a) * ColorModulator;
        return;
    }
#endif

    if (color.a < 0.1) {
        discard;
    }

    #ifdef OIT_ALPHA_ONLY
    executeAlphaOnlyPhase(gl_FragCoord.z, color.a);
    #else
    fragColor = calculateFinalColor(color);
    #endif
}