Shader "Custom/WaterShader"
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
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent"  }
        LOD 100

        Pass
        {
            Name "TestPass"
            
            HLSLPROGRAM //Start HLSL code

            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile_fog


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
                half3 normal : NORMAL;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                half3 normal : TEXCOORD0;
                float fogCoords : TEXCOORD1;
                float4 scrPos : TEXCOORD2;
            };

            float3 CalculatePosition(float Ws, float Wl, float3 Wd, float3 pos, inout float3 tangent, inout float3 binormal)
            {
                float k = (2 * 3.141593) / Wl;
                float c = sqrt(9.806 / k);
                float3 d = normalize(Wd);
                float f = k * (dot(d, pos) - c * _ActualTime);
                float a = Ws / k;

                tangent += float3(
                    -d.x * d.y * (Ws * sin(f)),
                    d.x * (Ws * cos(f)),
                    -d.x * d.y * (Ws * sin(f))
                    );

                binormal += float3(
                    -d.x * d.y * (Ws * sin(f)),
                    d.y * (Ws * cos(f)),
                    -d.y + d.y + (Ws * sin(f))
                    );

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
                
                float3 tangent = float3(1,0,0);
                float3 binormal = float3(0,0,1);

                input.vertex.xyz += CalculatePosition(_WaveStrength,_WaveLength,_WaveDirection,worldPos.xyz, tangent, binormal);
                input.vertex.xyz += CalculatePosition(_WaveStrength2,_WaveLength2,_WaveDirection2,worldPos.xyz, tangent, binormal);
                input.vertex.xyz += CalculatePosition(_WaveStrength3,_WaveLength3,_WaveDirection3,worldPos.xyz, tangent, binormal);

                VertexPositionInputs posIn = GetVertexPositionInputs(input.vertex.xyz);
                 
                output.vertex = posIn.positionCS;
                //output.uv = _MainTex;
                float3 normal = normalize(cross(binormal, tangent));
                output.scrPos = posIn.positionNDC; // grab position on screen
                output.fogCoords = ComputeFogFactor (output.vertex.z);
                //output.normal = float4(normal.x, normal.y, normal.z, 0);
                output.normal = TransformObjectToWorldNormal(normal);
                return output;
            }

            float4 Fragment(v2f input) : SV_TARGET
            {
                return float4(0.3,0.3,1,1);
            }


            ENDHLSL
        }
    }
}
