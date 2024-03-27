#ifndef GerthnerWaveNode
#define GerthnerWaveNode

void CalculatePosition_float(float Ws, float Wl, float3 Wd, float3 pos, float _ActualTime, float3 tangent, float3 binormal, out float3 OUT, out float3 TAN, out float3 BIN)
{
    float k = (2 * 3.141593) / Wl;
    float c = sqrt(9.806 / k);
    float3 d = normalize(Wd);
    float f = k * (dot(d, pos) - c * _ActualTime);
    float a = Ws / k;

    TAN = tangent + float3(
                    -d.x * d.y * (Ws * sin(f)),
                    d.x * (Ws * cos(f)),
                    -d.x * d.y * (Ws * sin(f))
                    );

    BIN = binormal + float3(
                    -d.x * d.y * (Ws * sin(f)),
                    d.y * (Ws * cos(f)),
                    -d.y + d.y + (Ws * sin(f))
                    );

    OUT = float3(
                    (d.x * (a * cos(f))),
                    (a * sin(f)),
                    (d.y * (a * cos(f)))
                    );
}

#endif