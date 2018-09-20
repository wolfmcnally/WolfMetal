//
//  AngularGradientShader.metal
//  WolfMetal
//
//  Created by Wolf McNally on 8/5/17.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#include <metal_stdlib>
#import <simd/simd.h>

using namespace metal;

typedef struct {
    vector_float4 color;
    float frac;
    float bias;
} GradientElement;

typedef struct {
    vector_float2 center;
    float initialAngle;
    float innerRadius;
    float outerRadius;
    bool isOpaque;
    bool isClockwise;
    bool isFlipped;
    int32_t elementsCount;
} AngularGradientShaderParams;

template<typename T>
inline
T linestep(T edge0, T edge1, T x, bool isHermite) {
    T t = clamp((x - edge0)/(edge1 - edge0), T(0), T(1));
    return isHermite ? t * t * (3 - 2 * t) : t;
}

float4 colorInGradient(float frac, constant GradientElement *elements, const int count);
float4 colorInGradient(float frac, constant GradientElement *elements, const int count) {
    int lastIndex = count - 1;
    float4 startColor = float4(0.1, 0.1, 0.1, 1.0);
    float4 endColor = float4(1, 1, 1, 1);
    float startFrac = 0;
    float bias = 0.5;
    float endFrac = 1;

    switch(count) {
        case 0:
            endColor = float4(0.1, 0.1, 0.1, 1.0);
            break;
        case 1:
            startColor = elements[0].color;
            endColor = startColor;
            break;
        default:
            startColor = float4(1);
            endColor = float4(1);
            if(frac <= elements[0].frac) {
                startColor = elements[0].color;
                endColor = startColor;
            } else if(frac >= elements[lastIndex].frac) {
                startColor = elements[lastIndex].color;
                endColor = startColor;
                startFrac = elements[lastIndex].frac;
            } else {
                for(int index = 0; index < lastIndex; index++) {
                    GradientElement elem1 = elements[index];
                    GradientElement elem2 = elements[index + 1];
                    if(frac >= elem1.frac && frac <= elem2.frac) {
                        startColor = elem1.color;
                        endColor = elem2.color;
                        startFrac = elem1.frac;
                        endFrac = elem2.frac;
                        bias = elem1.bias;
                        break;
                    } else {
                        startColor = float4(1);
                        endColor = startColor;
                    }
                }
            }
            break;
    }

    float midFrac = mix(startFrac, endFrac, bias);
    float4 midColor = mix(startColor, endColor, 0.5);

    bool isHermite = false;

    if(frac < midFrac) {
        float t = linestep(startFrac, midFrac, frac, isHermite);
        return mix(startColor, midColor, t);
    } else {
        float t = linestep(midFrac, endFrac, frac, isHermite);
        return mix(midColor, endColor, t);
    }
}

kernel void
angularGradientShader(
                      constant AngularGradientShaderParams & params [[buffer(0)]],
                      constant GradientElement *elements [[buffer(1)]],
                      texture2d<float, access::write> outTexture [[texture(0)]],
                      uint2 gid [[thread_position_in_grid]]
                      )
{
    float4 outColor = float4(0);
    if(params.isOpaque) {
        outColor.a = 1;
    }

    float2 p = float2(gid) + 0.5;
    if(params.isFlipped) {
        p.y = outTexture.get_height() - p.y;
    }

    float2 center = params.center;
    float2 delta = p - center;
    float len = length(delta);
    if(len >= params.innerRadius) {
        if(params.outerRadius <= 0 || len <= params.outerRadius) {
            const float twopi = 2.0 * M_PI_F;
            float angle = atan2(delta.y, delta.x);

            float frac = fmod((angle + params.initialAngle + twopi) / twopi, 1);

            if(params.isClockwise) {
                frac = 1.0 - frac;
            }

            outColor = colorInGradient(frac, elements, params.elementsCount);
        }
    }
    
    outTexture.write(outColor, gid, 0);
}
