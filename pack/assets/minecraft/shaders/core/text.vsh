#version 330

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:sample_lightmap.glsl>
#endif

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
in ivec2 UV2;
#endif

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
uniform sampler2D Sampler2;
out float sphericalVertexDistance;
out float cylindricalVertexDistance;
#endif

out vec4 vertexColor;
out vec2 texCoord0;

const vec3 EASE_OUT_SMALL_COLOR = vec3(100.0f, 36.0f, 36.0f) / 255.0f;
const vec3 EASE_OUT_BIG_COLOR = vec3(100.0f, 36.0f, 40.0f) / 255.0f;
const vec3 WIPE_LEFT_COLOR = vec3(100.0f, 36.0f, 44.0f) / 255.0f;
const vec3 WIPE_RIGHT_COLOR = vec3(100.0f, 36.0f, 48.0f) / 255.0f;
const vec3 EASE_OUT_SMALL_OPAQUE_COLOR = vec3(100.0f, 36.0f, 52.0f) / 255.0f;
const vec3 EASE_OUT_BIG_OPAQUE_COLOR = vec3(100.0f, 36.0f, 56.0f) / 255.0f;

float easeOutExp(float x) {
    return 1 - pow(2, -10 * x);
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

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    #if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
        sphericalVertexDistance = fog_spherical_distance(Position);
        cylindricalVertexDistance = fog_cylindrical_distance(Position);
        vertexColor = Color * sample_lightmap(Sampler2, UV2);
    #else
        vertexColor = Color;
    #endif
        texCoord0 = UV0;

    // color definitions

    if (similar(Color, EASE_OUT_SMALL_COLOR)) {
        float scale = easeOutExp(Color.a);
        gl_Position.xy *= scale;
        vertexColor = vec4(1, 1, 1, Color.a);
    } else if (similarShadow(Color, EASE_OUT_SMALL_COLOR)) {
        float scale = easeOutExp(Color.a);
        gl_Position.xy *= scale;
        vertexColor = vec4(0.25, 0.25, 0.25, Color.a);
    }

    else if (similar(Color, EASE_OUT_BIG_COLOR)) {
        float scale = (1 - easeOutExp(Color.a)) + 1;
        gl_Position.xy *= scale;
        vertexColor = vec4(1, 1, 1, Color.a);
    } else if (similarShadow(Color, EASE_OUT_BIG_COLOR)) {
        float scale = (1 - easeOutExp(Color.a)) + 1;
        gl_Position.xy *= scale;
        vertexColor = vec4(0.25, 0.25, 0.25, Color.a);
    }

    if (similar(Color, EASE_OUT_SMALL_OPAQUE_COLOR)) {
        float scale = easeOutExp(Color.a);
        gl_Position.xy *= scale;
        vertexColor = vec4(1, 1, 1, 1);
    } else if (similarShadow(Color, EASE_OUT_SMALL_OPAQUE_COLOR)) {
        float scale = easeOutExp(Color.a);
        gl_Position.xy *= scale;
        vertexColor = vec4(0.25, 0.25, 0.25, 1);
    }

    else if (similar(Color, EASE_OUT_BIG_OPAQUE_COLOR)) {
        float scale = (1 - easeOutExp(Color.a)) + 1;
        gl_Position.xy *= scale;
        vertexColor = vec4(1, 1, 1, 1);
    } else if (similarShadow(Color, EASE_OUT_BIG_OPAQUE_COLOR)) {
        float scale = (1 - easeOutExp(Color.a)) + 1;
        gl_Position.xy *= scale;
        vertexColor = vec4(0.25, 0.25, 0.25, 1);
    }

    else if (similar(Color, WIPE_LEFT_COLOR) || similar(Color, WIPE_RIGHT_COLOR)) {
        vertexColor = Color;
    } else if (similarShadow(Color, WIPE_LEFT_COLOR) || similarShadow(Color, WIPE_RIGHT_COLOR)) {
        vertexColor = Color;
    }
}