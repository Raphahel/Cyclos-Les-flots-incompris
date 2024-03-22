Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}


        _WaveStrength("WaveStrength", Float) = 3
        _WaveLength("Wavelength", Float) = 3
        _WaveDirection("WaveDirection", Vector) = (0,0,1)

        _WaveStrength2("WaveStrength2", Float) = 3
        _WaveLength2("Wavelength2", Float) = 3
        _WaveDirection2("WaveDirection2", Vector) = (0,0,1)


        _WaveStrength3("WaveStrength3", Float) = 3
        _WaveLength3("Wavelength3", Float) = 3
        _WaveDirection3("WaveDirection3", Vector) = (0,0,1)


        _PI("PI", Float) = 3.14159265
        _ActualTime("actualTime", float) = 0
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Name "TestPass"
            
            HLSLPROGRAM //Start HLSL code

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float _PI;
            float2 _MainTex;

            float _WaveStrength;
            float _WaveLength;
            float3 _WaveDirection;

            float _WaveStrength2;
            float _WaveLength2;
            float3 _WaveDirection2;

            float _WaveStrength3;
            float _WaveLength3;
            float3 _WaveDirection3;

            float _ActualTime;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float fogCoords : TEXCOORD1;
                float4 scrPos : TEXCOORD2;
            };

            float3 CalculatePosition(float Ws, float Wl, float3 Wd, float3 pos)
            {
                float k = (2 * PI) / Wl;
                float c = sqrt(9.806 / k);
                float3 d = normalize(Wd);
                float f = k * (dot(d, pos) - c * _ActualTime);
                float a = Ws / k;

                return float3(
                    (d.x * (a * cos(f))), 
                    (a * sin(f)),
                    (d.y * (a * cos(f))) 
                    );
            }

            v2f Vertex(appdata input)
            {
                v2f output;

                
                float4 worldPos = mul(unity_ObjectToWorld, input.vertex);

                input.vertex.xyz += CalculatePosition(_WaveStrength,_WaveLength,_WaveDirection,worldPos.xyz);
                input.vertex.xyz += CalculatePosition(_WaveStrength2,_WaveLength2,_WaveDirection2,worldPos.xyz);
                input.vertex.xyz += CalculatePosition(_WaveStrength3,_WaveLength3,_WaveDirection3,worldPos.xyz);

                VertexPositionInputs posIn = GetVertexPositionInputs(input.vertex.xyz);
                 
                output.vertex = posIn.positionCS;
                output.uv = _MainTex;
                output.scrPos = posIn.positionNDC; // grab position on screen
                output.fogCoords = ComputeFogFactor (output.vertex.z);

                return output;
            }

            float4 Fragment(v2f input) : SV_TARGET
            {
                return float4(1,1,1,1);
            }


            ENDHLSL
        }
    }
}
