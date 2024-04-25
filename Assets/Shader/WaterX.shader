Shader "Shader Graphs/ShaderEauFinal"
{
    Properties
    {
        _Noise("Noise", Float) = 0.1
        _Smothnesss("Smothnesss", Range(0, 1)) = 0.5
        _ShallowWaterColor("ShallowWaterColor", Color) = (0, 0.01834917, 1, 0)
        _DeepWaterColor("DeepWaterColor", Color) = (0.02149342, 0.04799407, 0.1981132, 0)
        _Depth("Depth", Range(0, 1)) = 0
        _Strength("Strength", Range(0, 2)) = 0
        _FoamSpeed("FoamSpeed", Float) = 1
        _foamSize("foamSize", Float) = 5
        [HDR]_FoamColor("FoamColor", Color) = (8, 8, 8, 1)
        _FoamDepth("FoamDepth", Float) = 0
        _FoamStrength("FoamStrength", Float) = 1
        _WaveSteepness("WaveSteepness", Range(0, 1)) = 0.4
        _WaveLength("WaveLength", Float) = 15
        _WaveDirection("WaveDirection", Vector) = (0, 0, 1, 0)
        _WaveSteepness2("WaveSteepness2", Range(0, 1)) = 0.3
        _WaveLength2("WaveLength2", Float) = 1
        _WaveDirection2("WaveDirection2", Vector) = (1, 0, 1, 0)
        _WaveSteepness3("WaveSteepness3", Range(0, 1)) = 0
        _WaveLength3("WaveLength3", Float) = 3
        _WaveDirection3("WaveDirection3", Vector) = (0.3, 0, 0, 0)
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        //#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        //#pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _ShallowWaterColor;
        float _Depth;
        float4 _DeepWaterColor;
        float _Strength;
        float _FoamSpeed;
        float _foamSize;
        float4 _FoamColor;
        float _FoamDepth;
        float _FoamStrength;
        float _WaveSteepness;
        float _WaveLength;
        float _WaveLength2;
        float3 _WaveDirection2;
        float _WaveSteepness2;
        float3 _WaveDirection;
        float _WaveSteepness3;
        float _WaveLength3;
        float3 _WaveDirection3;
        float _Noise;
        float _Smothnesss;
        CBUFFER_END
        
        
        // Object and Global properties
        float _ActualTime;
        
        // Graph Includes
        #include "Assets/Shader/GerthnerWaveNode.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_SquareRoot_float(float In, out float Out)
        {
            Out = sqrt(In);
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            float3 worldDerivativeX = ddx(Position);
            float3 worldDerivativeY = ddy(Position);
        
            float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
            float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
            float d = dot(worldDerivativeX, crossY);
            float sgn = d < 0.0 ? (-1.0f) : 1.0f;
            float surface = sgn / max(0.000000000000001192093f, abs(d));
        
            float dHdx = ddx(In);
            float dHdy = ddy(In);
            float3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
            Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
            Out = TransformWorldToTangent(Out, TangentMatrix);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float = _WaveSteepness;
            float _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float = _WaveLength;
            float3 _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3 = _WaveDirection;
            float _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3;
            CalculatePosition_float(_Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float, _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float, _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3, IN.WorldSpacePosition, _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float, float3 (1, 0, 0), float3 (0, 0, 1), _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3);
            float3 _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3);
            float _Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float = _WaveSteepness2;
            float _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float = _WaveLength2;
            float3 _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3 = _WaveDirection2;
            float _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3;
            CalculatePosition_float(_Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float, _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float, _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3, IN.WorldSpacePosition, _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3);
            float3 _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3;
            Unity_Add_float3(_Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3);
            float _Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float = _WaveSteepness3;
            float _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float = _WaveLength3;
            float3 _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3 = _WaveDirection3;
            float _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3;
            CalculatePosition_float(_Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float, _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float, _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3, IN.WorldSpacePosition, _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3);
            float3 _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            Unity_Add_float3(_Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3);
            float3 _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3;
            Unity_CrossProduct_float(_CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3);
            float3 _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            Unity_Normalize_float3(_CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3, _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3);
            description.Position = _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            description.Normal = _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            description.Tangent = _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4 = _ShallowWaterColor;
            float4 _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float);
            float _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float, _ProjectionParams.z, _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float);
            float4 _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_R_1_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[0];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_G_2_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[1];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_B_3_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[2];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[3];
            float _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float = _Depth;
            float _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float;
            Unity_Add_float(_Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float, _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float);
            float _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float;
            Unity_Subtract_float(_Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float, _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float);
            float _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float = _Strength;
            float _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float, _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float, _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float);
            float _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float;
            Unity_Clamp_float(_Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float, 0, 1, _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float);
            float4 _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4;
            Unity_Lerp_float4(_Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4, _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4, (_Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float.xxxx), _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4);
            float4 _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FoamColor) : _FoamColor;
            float _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float);
            float _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float, _ProjectionParams.z, _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float);
            float4 _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_f65f59f489f64ee888024c54d0ce44d8_R_1_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[0];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_G_2_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[1];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_B_3_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[2];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[3];
            float _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float = _FoamDepth;
            float _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float;
            Unity_Add_float(_Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float, _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float);
            float _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float;
            Unity_Subtract_float(_Multiply_0842fa15872b40678e800db729b00908_Out_2_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float, _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float);
            float _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float = _FoamStrength;
            float _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float, _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float, _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float);
            float _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float = _FoamSpeed;
            float _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float, _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float);
            float2 _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float.xx), _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2);
            float _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float = _foamSize;
            float _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2, _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float);
            float _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float;
            Unity_Step_float(_Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float, _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float);
            float4 _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4, _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4, (_Step_a521d8395f7842529b00669ed29532ab_Out_2_Float.xxxx), _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4);
            float _Split_04fc4696b65d4bba8035f681683c97bf_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_04fc4696b65d4bba8035f681683c97bf_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_04fc4696b65d4bba8035f681683c97bf_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_04fc4696b65d4bba8035f681683c97bf_A_4_Float = 0;
            float2 _Vector2_16ea670576b24f14ad04c034da51882b_Out_0_Vector2 = float2(_Split_04fc4696b65d4bba8035f681683c97bf_R_1_Float, _Split_04fc4696b65d4bba8035f681683c97bf_B_3_Float);
            float3 _Property_ba496ec6e1da436988cffd57e7d9b788_Out_0_Vector3 = _WaveDirection;
            float3 _Normalize_18bddd1247574bc3a54cbbe756940237_Out_1_Vector3;
            Unity_Normalize_float3(_Property_ba496ec6e1da436988cffd57e7d9b788_Out_0_Vector3, _Normalize_18bddd1247574bc3a54cbbe756940237_Out_1_Vector3);
            float _DotProduct_169e326f0c2b4469b126839b580f7c99_Out_2_Float;
            Unity_DotProduct_float3(_Normalize_18bddd1247574bc3a54cbbe756940237_Out_1_Vector3, IN.WorldSpacePosition, _DotProduct_169e326f0c2b4469b126839b580f7c99_Out_2_Float);
            float Constant_61934a838e4d4d23a7c1bb198488139c = 6.283185;
            float _Property_679a79338b3047e2a268f87f0262c65b_Out_0_Float = _WaveLength;
            float _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float;
            Unity_Divide_float(Constant_61934a838e4d4d23a7c1bb198488139c, _Property_679a79338b3047e2a268f87f0262c65b_Out_0_Float, _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float);
            float _Multiply_5e91ae06fd5447a2be87ad6730c34a9c_Out_2_Float;
            Unity_Multiply_float_float(_DotProduct_169e326f0c2b4469b126839b580f7c99_Out_2_Float, _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float, _Multiply_5e91ae06fd5447a2be87ad6730c34a9c_Out_2_Float);
            float _Divide_136d6a2b734848f3afb6f3494352ad3e_Out_2_Float;
            Unity_Divide_float(9.8, _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float, _Divide_136d6a2b734848f3afb6f3494352ad3e_Out_2_Float);
            float _SquareRoot_737883c364ad4a388545d25a20ab0f6d_Out_1_Float;
            Unity_SquareRoot_float(_Divide_136d6a2b734848f3afb6f3494352ad3e_Out_2_Float, _SquareRoot_737883c364ad4a388545d25a20ab0f6d_Out_1_Float);
            float _Multiply_35680f9e58f2406384b59b604d07649d_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _SquareRoot_737883c364ad4a388545d25a20ab0f6d_Out_1_Float, _Multiply_35680f9e58f2406384b59b604d07649d_Out_2_Float);
            float _Subtract_0c0f516a6f16431cb292935ebea1bf9e_Out_2_Float;
            Unity_Subtract_float(_Multiply_5e91ae06fd5447a2be87ad6730c34a9c_Out_2_Float, _Multiply_35680f9e58f2406384b59b604d07649d_Out_2_Float, _Subtract_0c0f516a6f16431cb292935ebea1bf9e_Out_2_Float);
            float _Multiply_2c004490b5184062a6dd3ffe7b7ae227_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_0c0f516a6f16431cb292935ebea1bf9e_Out_2_Float, _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float, _Multiply_2c004490b5184062a6dd3ffe7b7ae227_Out_2_Float);
            float2 _TilingAndOffset_2a92b29a659d43c0b19815c4320f916f_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Vector2_16ea670576b24f14ad04c034da51882b_Out_0_Vector2, float2 (1, 1), (_Multiply_2c004490b5184062a6dd3ffe7b7ae227_Out_2_Float.xx), _TilingAndOffset_2a92b29a659d43c0b19815c4320f916f_Out_3_Vector2);
            float _Property_73cea0ad8f1147b88cc730e64c071883_Out_0_Float = _Noise;
            float _GradientNoise_483d65913ffb4a1b84825366e05fb0fd_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_2a92b29a659d43c0b19815c4320f916f_Out_3_Vector2, _Property_73cea0ad8f1147b88cc730e64c071883_Out_0_Float, _GradientNoise_483d65913ffb4a1b84825366e05fb0fd_Out_2_Float);
            float3 _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Out_1_Vector3;
            float3x3 _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_GradientNoise_483d65913ffb4a1b84825366e05fb0fd_Out_2_Float,0.3,_NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Position,_NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_TangentMatrix, _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Out_1_Vector3);
            float _Property_bccf6d227af346ba9ececd4c5760ddf6_Out_0_Float = _Smothnesss;
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_R_1_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[0];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_G_2_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[1];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_B_3_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[2];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[3];
            surface.BaseColor = (_Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4.xyz);
            surface.NormalTS = _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Out_1_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = _Property_bccf6d227af346ba9ececd4c5760ddf6_Out_0_Float;
            surface.Occlusion = 1;
            surface.Alpha = _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _ShallowWaterColor;
        float _Depth;
        float4 _DeepWaterColor;
        float _Strength;
        float _FoamSpeed;
        float _foamSize;
        float4 _FoamColor;
        float _FoamDepth;
        float _FoamStrength;
        float _WaveSteepness;
        float _WaveLength;
        float _WaveLength2;
        float3 _WaveDirection2;
        float _WaveSteepness2;
        float3 _WaveDirection;
        float _WaveSteepness3;
        float _WaveLength3;
        float3 _WaveDirection3;
        float _Noise;
        float _Smothnesss;
        CBUFFER_END
        
        
        // Object and Global properties
        float _ActualTime;
        
        // Graph Includes
        #include "Assets/Shader/GerthnerWaveNode.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_SquareRoot_float(float In, out float Out)
        {
            Out = sqrt(In);
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            float3 worldDerivativeX = ddx(Position);
            float3 worldDerivativeY = ddy(Position);
        
            float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
            float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
            float d = dot(worldDerivativeX, crossY);
            float sgn = d < 0.0 ? (-1.0f) : 1.0f;
            float surface = sgn / max(0.000000000000001192093f, abs(d));
        
            float dHdx = ddx(In);
            float dHdy = ddy(In);
            float3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
            Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
            Out = TransformWorldToTangent(Out, TangentMatrix);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float = _WaveSteepness;
            float _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float = _WaveLength;
            float3 _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3 = _WaveDirection;
            float _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3;
            CalculatePosition_float(_Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float, _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float, _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3, IN.WorldSpacePosition, _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float, float3 (1, 0, 0), float3 (0, 0, 1), _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3);
            float3 _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3);
            float _Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float = _WaveSteepness2;
            float _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float = _WaveLength2;
            float3 _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3 = _WaveDirection2;
            float _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3;
            CalculatePosition_float(_Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float, _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float, _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3, IN.WorldSpacePosition, _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3);
            float3 _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3;
            Unity_Add_float3(_Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3);
            float _Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float = _WaveSteepness3;
            float _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float = _WaveLength3;
            float3 _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3 = _WaveDirection3;
            float _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3;
            CalculatePosition_float(_Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float, _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float, _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3, IN.WorldSpacePosition, _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3);
            float3 _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            Unity_Add_float3(_Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3);
            float3 _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3;
            Unity_CrossProduct_float(_CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3);
            float3 _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            Unity_Normalize_float3(_CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3, _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3);
            description.Position = _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            description.Normal = _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            description.Tangent = _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4 = _ShallowWaterColor;
            float4 _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float);
            float _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float, _ProjectionParams.z, _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float);
            float4 _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_R_1_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[0];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_G_2_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[1];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_B_3_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[2];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[3];
            float _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float = _Depth;
            float _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float;
            Unity_Add_float(_Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float, _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float);
            float _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float;
            Unity_Subtract_float(_Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float, _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float);
            float _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float = _Strength;
            float _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float, _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float, _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float);
            float _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float;
            Unity_Clamp_float(_Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float, 0, 1, _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float);
            float4 _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4;
            Unity_Lerp_float4(_Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4, _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4, (_Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float.xxxx), _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4);
            float4 _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FoamColor) : _FoamColor;
            float _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float);
            float _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float, _ProjectionParams.z, _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float);
            float4 _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_f65f59f489f64ee888024c54d0ce44d8_R_1_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[0];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_G_2_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[1];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_B_3_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[2];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[3];
            float _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float = _FoamDepth;
            float _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float;
            Unity_Add_float(_Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float, _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float);
            float _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float;
            Unity_Subtract_float(_Multiply_0842fa15872b40678e800db729b00908_Out_2_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float, _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float);
            float _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float = _FoamStrength;
            float _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float, _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float, _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float);
            float _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float = _FoamSpeed;
            float _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float, _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float);
            float2 _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float.xx), _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2);
            float _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float = _foamSize;
            float _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2, _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float);
            float _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float;
            Unity_Step_float(_Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float, _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float);
            float4 _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4, _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4, (_Step_a521d8395f7842529b00669ed29532ab_Out_2_Float.xxxx), _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4);
            float _Split_04fc4696b65d4bba8035f681683c97bf_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_04fc4696b65d4bba8035f681683c97bf_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_04fc4696b65d4bba8035f681683c97bf_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_04fc4696b65d4bba8035f681683c97bf_A_4_Float = 0;
            float2 _Vector2_16ea670576b24f14ad04c034da51882b_Out_0_Vector2 = float2(_Split_04fc4696b65d4bba8035f681683c97bf_R_1_Float, _Split_04fc4696b65d4bba8035f681683c97bf_B_3_Float);
            float3 _Property_ba496ec6e1da436988cffd57e7d9b788_Out_0_Vector3 = _WaveDirection;
            float3 _Normalize_18bddd1247574bc3a54cbbe756940237_Out_1_Vector3;
            Unity_Normalize_float3(_Property_ba496ec6e1da436988cffd57e7d9b788_Out_0_Vector3, _Normalize_18bddd1247574bc3a54cbbe756940237_Out_1_Vector3);
            float _DotProduct_169e326f0c2b4469b126839b580f7c99_Out_2_Float;
            Unity_DotProduct_float3(_Normalize_18bddd1247574bc3a54cbbe756940237_Out_1_Vector3, IN.WorldSpacePosition, _DotProduct_169e326f0c2b4469b126839b580f7c99_Out_2_Float);
            float Constant_61934a838e4d4d23a7c1bb198488139c = 6.283185;
            float _Property_679a79338b3047e2a268f87f0262c65b_Out_0_Float = _WaveLength;
            float _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float;
            Unity_Divide_float(Constant_61934a838e4d4d23a7c1bb198488139c, _Property_679a79338b3047e2a268f87f0262c65b_Out_0_Float, _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float);
            float _Multiply_5e91ae06fd5447a2be87ad6730c34a9c_Out_2_Float;
            Unity_Multiply_float_float(_DotProduct_169e326f0c2b4469b126839b580f7c99_Out_2_Float, _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float, _Multiply_5e91ae06fd5447a2be87ad6730c34a9c_Out_2_Float);
            float _Divide_136d6a2b734848f3afb6f3494352ad3e_Out_2_Float;
            Unity_Divide_float(9.8, _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float, _Divide_136d6a2b734848f3afb6f3494352ad3e_Out_2_Float);
            float _SquareRoot_737883c364ad4a388545d25a20ab0f6d_Out_1_Float;
            Unity_SquareRoot_float(_Divide_136d6a2b734848f3afb6f3494352ad3e_Out_2_Float, _SquareRoot_737883c364ad4a388545d25a20ab0f6d_Out_1_Float);
            float _Multiply_35680f9e58f2406384b59b604d07649d_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _SquareRoot_737883c364ad4a388545d25a20ab0f6d_Out_1_Float, _Multiply_35680f9e58f2406384b59b604d07649d_Out_2_Float);
            float _Subtract_0c0f516a6f16431cb292935ebea1bf9e_Out_2_Float;
            Unity_Subtract_float(_Multiply_5e91ae06fd5447a2be87ad6730c34a9c_Out_2_Float, _Multiply_35680f9e58f2406384b59b604d07649d_Out_2_Float, _Subtract_0c0f516a6f16431cb292935ebea1bf9e_Out_2_Float);
            float _Multiply_2c004490b5184062a6dd3ffe7b7ae227_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_0c0f516a6f16431cb292935ebea1bf9e_Out_2_Float, _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float, _Multiply_2c004490b5184062a6dd3ffe7b7ae227_Out_2_Float);
            float2 _TilingAndOffset_2a92b29a659d43c0b19815c4320f916f_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Vector2_16ea670576b24f14ad04c034da51882b_Out_0_Vector2, float2 (1, 1), (_Multiply_2c004490b5184062a6dd3ffe7b7ae227_Out_2_Float.xx), _TilingAndOffset_2a92b29a659d43c0b19815c4320f916f_Out_3_Vector2);
            float _Property_73cea0ad8f1147b88cc730e64c071883_Out_0_Float = _Noise;
            float _GradientNoise_483d65913ffb4a1b84825366e05fb0fd_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_2a92b29a659d43c0b19815c4320f916f_Out_3_Vector2, _Property_73cea0ad8f1147b88cc730e64c071883_Out_0_Float, _GradientNoise_483d65913ffb4a1b84825366e05fb0fd_Out_2_Float);
            float3 _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Out_1_Vector3;
            float3x3 _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_GradientNoise_483d65913ffb4a1b84825366e05fb0fd_Out_2_Float,0.3,_NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Position,_NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_TangentMatrix, _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Out_1_Vector3);
            float _Property_bccf6d227af346ba9ececd4c5760ddf6_Out_0_Float = _Smothnesss;
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_R_1_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[0];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_G_2_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[1];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_B_3_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[2];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[3];
            surface.BaseColor = (_Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4.xyz);
            surface.NormalTS = _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Out_1_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = _Property_bccf6d227af346ba9ececd4c5760ddf6_Out_0_Float;
            surface.Occlusion = 1;
            surface.Alpha = _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _ShallowWaterColor;
        float _Depth;
        float4 _DeepWaterColor;
        float _Strength;
        float _FoamSpeed;
        float _foamSize;
        float4 _FoamColor;
        float _FoamDepth;
        float _FoamStrength;
        float _WaveSteepness;
        float _WaveLength;
        float _WaveLength2;
        float3 _WaveDirection2;
        float _WaveSteepness2;
        float3 _WaveDirection;
        float _WaveSteepness3;
        float _WaveLength3;
        float3 _WaveDirection3;
        float _Noise;
        float _Smothnesss;
        CBUFFER_END
        
        
        // Object and Global properties
        float _ActualTime;
        
        // Graph Includes
        #include "Assets/Shader/GerthnerWaveNode.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_SquareRoot_float(float In, out float Out)
        {
            Out = sqrt(In);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            float3 worldDerivativeX = ddx(Position);
            float3 worldDerivativeY = ddy(Position);
        
            float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
            float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
            float d = dot(worldDerivativeX, crossY);
            float sgn = d < 0.0 ? (-1.0f) : 1.0f;
            float surface = sgn / max(0.000000000000001192093f, abs(d));
        
            float dHdx = ddx(In);
            float dHdy = ddy(In);
            float3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
            Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
            Out = TransformWorldToTangent(Out, TangentMatrix);
        }
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float = _WaveSteepness;
            float _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float = _WaveLength;
            float3 _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3 = _WaveDirection;
            float _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3;
            CalculatePosition_float(_Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float, _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float, _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3, IN.WorldSpacePosition, _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float, float3 (1, 0, 0), float3 (0, 0, 1), _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3);
            float3 _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3);
            float _Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float = _WaveSteepness2;
            float _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float = _WaveLength2;
            float3 _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3 = _WaveDirection2;
            float _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3;
            CalculatePosition_float(_Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float, _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float, _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3, IN.WorldSpacePosition, _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3);
            float3 _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3;
            Unity_Add_float3(_Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3);
            float _Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float = _WaveSteepness3;
            float _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float = _WaveLength3;
            float3 _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3 = _WaveDirection3;
            float _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3;
            CalculatePosition_float(_Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float, _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float, _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3, IN.WorldSpacePosition, _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3);
            float3 _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            Unity_Add_float3(_Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3);
            float3 _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3;
            Unity_CrossProduct_float(_CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3);
            float3 _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            Unity_Normalize_float3(_CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3, _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3);
            description.Position = _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            description.Normal = _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            description.Tangent = _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Split_04fc4696b65d4bba8035f681683c97bf_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_04fc4696b65d4bba8035f681683c97bf_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_04fc4696b65d4bba8035f681683c97bf_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_04fc4696b65d4bba8035f681683c97bf_A_4_Float = 0;
            float2 _Vector2_16ea670576b24f14ad04c034da51882b_Out_0_Vector2 = float2(_Split_04fc4696b65d4bba8035f681683c97bf_R_1_Float, _Split_04fc4696b65d4bba8035f681683c97bf_B_3_Float);
            float3 _Property_ba496ec6e1da436988cffd57e7d9b788_Out_0_Vector3 = _WaveDirection;
            float3 _Normalize_18bddd1247574bc3a54cbbe756940237_Out_1_Vector3;
            Unity_Normalize_float3(_Property_ba496ec6e1da436988cffd57e7d9b788_Out_0_Vector3, _Normalize_18bddd1247574bc3a54cbbe756940237_Out_1_Vector3);
            float _DotProduct_169e326f0c2b4469b126839b580f7c99_Out_2_Float;
            Unity_DotProduct_float3(_Normalize_18bddd1247574bc3a54cbbe756940237_Out_1_Vector3, IN.WorldSpacePosition, _DotProduct_169e326f0c2b4469b126839b580f7c99_Out_2_Float);
            float Constant_61934a838e4d4d23a7c1bb198488139c = 6.283185;
            float _Property_679a79338b3047e2a268f87f0262c65b_Out_0_Float = _WaveLength;
            float _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float;
            Unity_Divide_float(Constant_61934a838e4d4d23a7c1bb198488139c, _Property_679a79338b3047e2a268f87f0262c65b_Out_0_Float, _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float);
            float _Multiply_5e91ae06fd5447a2be87ad6730c34a9c_Out_2_Float;
            Unity_Multiply_float_float(_DotProduct_169e326f0c2b4469b126839b580f7c99_Out_2_Float, _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float, _Multiply_5e91ae06fd5447a2be87ad6730c34a9c_Out_2_Float);
            float _Divide_136d6a2b734848f3afb6f3494352ad3e_Out_2_Float;
            Unity_Divide_float(9.8, _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float, _Divide_136d6a2b734848f3afb6f3494352ad3e_Out_2_Float);
            float _SquareRoot_737883c364ad4a388545d25a20ab0f6d_Out_1_Float;
            Unity_SquareRoot_float(_Divide_136d6a2b734848f3afb6f3494352ad3e_Out_2_Float, _SquareRoot_737883c364ad4a388545d25a20ab0f6d_Out_1_Float);
            float _Multiply_35680f9e58f2406384b59b604d07649d_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _SquareRoot_737883c364ad4a388545d25a20ab0f6d_Out_1_Float, _Multiply_35680f9e58f2406384b59b604d07649d_Out_2_Float);
            float _Subtract_0c0f516a6f16431cb292935ebea1bf9e_Out_2_Float;
            Unity_Subtract_float(_Multiply_5e91ae06fd5447a2be87ad6730c34a9c_Out_2_Float, _Multiply_35680f9e58f2406384b59b604d07649d_Out_2_Float, _Subtract_0c0f516a6f16431cb292935ebea1bf9e_Out_2_Float);
            float _Multiply_2c004490b5184062a6dd3ffe7b7ae227_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_0c0f516a6f16431cb292935ebea1bf9e_Out_2_Float, _Divide_6312bb1d74324e4a86a577ed177e85d8_Out_2_Float, _Multiply_2c004490b5184062a6dd3ffe7b7ae227_Out_2_Float);
            float2 _TilingAndOffset_2a92b29a659d43c0b19815c4320f916f_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Vector2_16ea670576b24f14ad04c034da51882b_Out_0_Vector2, float2 (1, 1), (_Multiply_2c004490b5184062a6dd3ffe7b7ae227_Out_2_Float.xx), _TilingAndOffset_2a92b29a659d43c0b19815c4320f916f_Out_3_Vector2);
            float _Property_73cea0ad8f1147b88cc730e64c071883_Out_0_Float = _Noise;
            float _GradientNoise_483d65913ffb4a1b84825366e05fb0fd_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_2a92b29a659d43c0b19815c4320f916f_Out_3_Vector2, _Property_73cea0ad8f1147b88cc730e64c071883_Out_0_Float, _GradientNoise_483d65913ffb4a1b84825366e05fb0fd_Out_2_Float);
            float3 _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Out_1_Vector3;
            float3x3 _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_GradientNoise_483d65913ffb4a1b84825366e05fb0fd_Out_2_Float,0.3,_NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Position,_NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_TangentMatrix, _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Out_1_Vector3);
            float4 _Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4 = _ShallowWaterColor;
            float4 _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float);
            float _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float, _ProjectionParams.z, _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float);
            float4 _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_R_1_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[0];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_G_2_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[1];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_B_3_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[2];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[3];
            float _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float = _Depth;
            float _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float;
            Unity_Add_float(_Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float, _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float);
            float _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float;
            Unity_Subtract_float(_Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float, _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float);
            float _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float = _Strength;
            float _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float, _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float, _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float);
            float _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float;
            Unity_Clamp_float(_Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float, 0, 1, _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float);
            float4 _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4;
            Unity_Lerp_float4(_Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4, _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4, (_Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float.xxxx), _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4);
            float4 _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FoamColor) : _FoamColor;
            float _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float);
            float _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float, _ProjectionParams.z, _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float);
            float4 _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_f65f59f489f64ee888024c54d0ce44d8_R_1_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[0];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_G_2_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[1];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_B_3_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[2];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[3];
            float _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float = _FoamDepth;
            float _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float;
            Unity_Add_float(_Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float, _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float);
            float _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float;
            Unity_Subtract_float(_Multiply_0842fa15872b40678e800db729b00908_Out_2_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float, _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float);
            float _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float = _FoamStrength;
            float _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float, _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float, _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float);
            float _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float = _FoamSpeed;
            float _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float, _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float);
            float2 _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float.xx), _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2);
            float _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float = _foamSize;
            float _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2, _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float);
            float _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float;
            Unity_Step_float(_Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float, _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float);
            float4 _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4, _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4, (_Step_a521d8395f7842529b00669ed29532ab_Out_2_Float.xxxx), _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4);
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_R_1_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[0];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_G_2_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[1];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_B_3_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[2];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[3];
            surface.NormalTS = _NormalFromHeight_319b4b79421f4d6f8edf1cee483cf4c2_Out_1_Vector3;
            surface.Alpha = _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float3 positionWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _ShallowWaterColor;
        float _Depth;
        float4 _DeepWaterColor;
        float _Strength;
        float _FoamSpeed;
        float _foamSize;
        float4 _FoamColor;
        float _FoamDepth;
        float _FoamStrength;
        float _WaveSteepness;
        float _WaveLength;
        float _WaveLength2;
        float3 _WaveDirection2;
        float _WaveSteepness2;
        float3 _WaveDirection;
        float _WaveSteepness3;
        float _WaveLength3;
        float3 _WaveDirection3;
        float _Noise;
        float _Smothnesss;
        CBUFFER_END
        
        
        // Object and Global properties
        float _ActualTime;
        
        // Graph Includes
        #include "Assets/Shader/GerthnerWaveNode.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float = _WaveSteepness;
            float _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float = _WaveLength;
            float3 _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3 = _WaveDirection;
            float _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3;
            CalculatePosition_float(_Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float, _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float, _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3, IN.WorldSpacePosition, _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float, float3 (1, 0, 0), float3 (0, 0, 1), _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3);
            float3 _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3);
            float _Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float = _WaveSteepness2;
            float _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float = _WaveLength2;
            float3 _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3 = _WaveDirection2;
            float _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3;
            CalculatePosition_float(_Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float, _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float, _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3, IN.WorldSpacePosition, _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3);
            float3 _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3;
            Unity_Add_float3(_Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3);
            float _Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float = _WaveSteepness3;
            float _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float = _WaveLength3;
            float3 _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3 = _WaveDirection3;
            float _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3;
            CalculatePosition_float(_Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float, _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float, _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3, IN.WorldSpacePosition, _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3);
            float3 _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            Unity_Add_float3(_Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3);
            float3 _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3;
            Unity_CrossProduct_float(_CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3);
            float3 _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            Unity_Normalize_float3(_CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3, _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3);
            description.Position = _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            description.Normal = _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            description.Tangent = _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4 = _ShallowWaterColor;
            float4 _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float);
            float _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float, _ProjectionParams.z, _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float);
            float4 _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_R_1_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[0];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_G_2_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[1];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_B_3_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[2];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[3];
            float _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float = _Depth;
            float _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float;
            Unity_Add_float(_Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float, _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float);
            float _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float;
            Unity_Subtract_float(_Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float, _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float);
            float _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float = _Strength;
            float _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float, _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float, _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float);
            float _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float;
            Unity_Clamp_float(_Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float, 0, 1, _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float);
            float4 _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4;
            Unity_Lerp_float4(_Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4, _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4, (_Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float.xxxx), _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4);
            float4 _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FoamColor) : _FoamColor;
            float _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float);
            float _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float, _ProjectionParams.z, _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float);
            float4 _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_f65f59f489f64ee888024c54d0ce44d8_R_1_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[0];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_G_2_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[1];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_B_3_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[2];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[3];
            float _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float = _FoamDepth;
            float _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float;
            Unity_Add_float(_Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float, _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float);
            float _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float;
            Unity_Subtract_float(_Multiply_0842fa15872b40678e800db729b00908_Out_2_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float, _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float);
            float _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float = _FoamStrength;
            float _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float, _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float, _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float);
            float _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float = _FoamSpeed;
            float _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float, _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float);
            float2 _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float.xx), _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2);
            float _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float = _foamSize;
            float _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2, _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float);
            float _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float;
            Unity_Step_float(_Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float, _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float);
            float4 _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4, _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4, (_Step_a521d8395f7842529b00669ed29532ab_Out_2_Float.xxxx), _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4);
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_R_1_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[0];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_G_2_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[1];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_B_3_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[2];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[3];
            surface.BaseColor = (_Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _ShallowWaterColor;
        float _Depth;
        float4 _DeepWaterColor;
        float _Strength;
        float _FoamSpeed;
        float _foamSize;
        float4 _FoamColor;
        float _FoamDepth;
        float _FoamStrength;
        float _WaveSteepness;
        float _WaveLength;
        float _WaveLength2;
        float3 _WaveDirection2;
        float _WaveSteepness2;
        float3 _WaveDirection;
        float _WaveSteepness3;
        float _WaveLength3;
        float3 _WaveDirection3;
        float _Noise;
        float _Smothnesss;
        CBUFFER_END
        
        
        // Object and Global properties
        float _ActualTime;
        
        // Graph Includes
        #include "Assets/Shader/GerthnerWaveNode.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float = _WaveSteepness;
            float _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float = _WaveLength;
            float3 _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3 = _WaveDirection;
            float _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3;
            CalculatePosition_float(_Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float, _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float, _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3, IN.WorldSpacePosition, _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float, float3 (1, 0, 0), float3 (0, 0, 1), _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3);
            float3 _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3);
            float _Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float = _WaveSteepness2;
            float _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float = _WaveLength2;
            float3 _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3 = _WaveDirection2;
            float _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3;
            CalculatePosition_float(_Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float, _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float, _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3, IN.WorldSpacePosition, _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3);
            float3 _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3;
            Unity_Add_float3(_Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3);
            float _Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float = _WaveSteepness3;
            float _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float = _WaveLength3;
            float3 _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3 = _WaveDirection3;
            float _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3;
            CalculatePosition_float(_Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float, _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float, _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3, IN.WorldSpacePosition, _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3);
            float3 _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            Unity_Add_float3(_Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3);
            float3 _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3;
            Unity_CrossProduct_float(_CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3);
            float3 _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            Unity_Normalize_float3(_CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3, _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3);
            description.Position = _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            description.Normal = _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            description.Tangent = _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4 = _ShallowWaterColor;
            float4 _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float);
            float _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float, _ProjectionParams.z, _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float);
            float4 _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_R_1_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[0];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_G_2_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[1];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_B_3_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[2];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[3];
            float _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float = _Depth;
            float _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float;
            Unity_Add_float(_Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float, _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float);
            float _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float;
            Unity_Subtract_float(_Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float, _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float);
            float _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float = _Strength;
            float _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float, _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float, _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float);
            float _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float;
            Unity_Clamp_float(_Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float, 0, 1, _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float);
            float4 _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4;
            Unity_Lerp_float4(_Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4, _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4, (_Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float.xxxx), _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4);
            float4 _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FoamColor) : _FoamColor;
            float _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float);
            float _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float, _ProjectionParams.z, _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float);
            float4 _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_f65f59f489f64ee888024c54d0ce44d8_R_1_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[0];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_G_2_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[1];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_B_3_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[2];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[3];
            float _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float = _FoamDepth;
            float _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float;
            Unity_Add_float(_Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float, _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float);
            float _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float;
            Unity_Subtract_float(_Multiply_0842fa15872b40678e800db729b00908_Out_2_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float, _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float);
            float _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float = _FoamStrength;
            float _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float, _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float, _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float);
            float _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float = _FoamSpeed;
            float _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float, _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float);
            float2 _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float.xx), _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2);
            float _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float = _foamSize;
            float _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2, _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float);
            float _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float;
            Unity_Step_float(_Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float, _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float);
            float4 _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4, _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4, (_Step_a521d8395f7842529b00669ed29532ab_Out_2_Float.xxxx), _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4);
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_R_1_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[0];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_G_2_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[1];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_B_3_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[2];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[3];
            surface.Alpha = _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _ShallowWaterColor;
        float _Depth;
        float4 _DeepWaterColor;
        float _Strength;
        float _FoamSpeed;
        float _foamSize;
        float4 _FoamColor;
        float _FoamDepth;
        float _FoamStrength;
        float _WaveSteepness;
        float _WaveLength;
        float _WaveLength2;
        float3 _WaveDirection2;
        float _WaveSteepness2;
        float3 _WaveDirection;
        float _WaveSteepness3;
        float _WaveLength3;
        float3 _WaveDirection3;
        float _Noise;
        float _Smothnesss;
        CBUFFER_END
        
        
        // Object and Global properties
        float _ActualTime;
        
        // Graph Includes
        #include "Assets/Shader/GerthnerWaveNode.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float = _WaveSteepness;
            float _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float = _WaveLength;
            float3 _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3 = _WaveDirection;
            float _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3;
            CalculatePosition_float(_Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float, _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float, _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3, IN.WorldSpacePosition, _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float, float3 (1, 0, 0), float3 (0, 0, 1), _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3);
            float3 _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3);
            float _Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float = _WaveSteepness2;
            float _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float = _WaveLength2;
            float3 _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3 = _WaveDirection2;
            float _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3;
            CalculatePosition_float(_Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float, _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float, _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3, IN.WorldSpacePosition, _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3);
            float3 _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3;
            Unity_Add_float3(_Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3);
            float _Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float = _WaveSteepness3;
            float _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float = _WaveLength3;
            float3 _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3 = _WaveDirection3;
            float _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3;
            CalculatePosition_float(_Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float, _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float, _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3, IN.WorldSpacePosition, _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3);
            float3 _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            Unity_Add_float3(_Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3);
            float3 _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3;
            Unity_CrossProduct_float(_CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3);
            float3 _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            Unity_Normalize_float3(_CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3, _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3);
            description.Position = _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            description.Normal = _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            description.Tangent = _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4 = _ShallowWaterColor;
            float4 _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float);
            float _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float, _ProjectionParams.z, _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float);
            float4 _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_R_1_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[0];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_G_2_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[1];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_B_3_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[2];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[3];
            float _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float = _Depth;
            float _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float;
            Unity_Add_float(_Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float, _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float);
            float _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float;
            Unity_Subtract_float(_Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float, _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float);
            float _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float = _Strength;
            float _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float, _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float, _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float);
            float _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float;
            Unity_Clamp_float(_Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float, 0, 1, _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float);
            float4 _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4;
            Unity_Lerp_float4(_Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4, _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4, (_Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float.xxxx), _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4);
            float4 _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FoamColor) : _FoamColor;
            float _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float);
            float _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float, _ProjectionParams.z, _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float);
            float4 _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_f65f59f489f64ee888024c54d0ce44d8_R_1_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[0];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_G_2_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[1];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_B_3_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[2];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[3];
            float _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float = _FoamDepth;
            float _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float;
            Unity_Add_float(_Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float, _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float);
            float _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float;
            Unity_Subtract_float(_Multiply_0842fa15872b40678e800db729b00908_Out_2_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float, _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float);
            float _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float = _FoamStrength;
            float _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float, _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float, _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float);
            float _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float = _FoamSpeed;
            float _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float, _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float);
            float2 _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float.xx), _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2);
            float _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float = _foamSize;
            float _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2, _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float);
            float _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float;
            Unity_Step_float(_Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float, _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float);
            float4 _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4, _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4, (_Step_a521d8395f7842529b00669ed29532ab_Out_2_Float.xxxx), _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4);
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_R_1_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[0];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_G_2_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[1];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_B_3_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[2];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[3];
            surface.Alpha = _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _ShallowWaterColor;
        float _Depth;
        float4 _DeepWaterColor;
        float _Strength;
        float _FoamSpeed;
        float _foamSize;
        float4 _FoamColor;
        float _FoamDepth;
        float _FoamStrength;
        float _WaveSteepness;
        float _WaveLength;
        float _WaveLength2;
        float3 _WaveDirection2;
        float _WaveSteepness2;
        float3 _WaveDirection;
        float _WaveSteepness3;
        float _WaveLength3;
        float3 _WaveDirection3;
        float _Noise;
        float _Smothnesss;
        CBUFFER_END
        
        
        // Object and Global properties
        float _ActualTime;
        
        // Graph Includes
        #include "Assets/Shader/GerthnerWaveNode.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float = _WaveSteepness;
            float _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float = _WaveLength;
            float3 _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3 = _WaveDirection;
            float _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3;
            CalculatePosition_float(_Property_f5273326a85b4c96920449b0da8becc9_Out_0_Float, _Property_6dee4340b0384ef3895823cc029af9c8_Out_0_Float, _Property_274d425d5e8e457280735b9fa01762c6_Out_0_Vector3, IN.WorldSpacePosition, _Property_29fd5eaca795419d973e6ef57c7433f1_Out_0_Float, float3 (1, 0, 0), float3 (0, 0, 1), _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3);
            float3 _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_OUT_5_Vector3, _Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3);
            float _Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float = _WaveSteepness2;
            float _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float = _WaveLength2;
            float3 _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3 = _WaveDirection2;
            float _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3;
            CalculatePosition_float(_Property_13da11d86e8b4eecb38be51dd22b4405_Out_0_Float, _Property_8a9fed482a4d41abb830b7650b71b016_Out_0_Float, _Property_f5b56ee756d24a35a67613e00f6ae09f_Out_0_Vector3, IN.WorldSpacePosition, _Property_d9ba7e7bdd6c42b98701439df682575a_Out_0_Float, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_TAN_8_Vector3, _CalculatePositionCustomFunction_74346299dab749c79f550e0c01f2e5c7_BIN_9_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3);
            float3 _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3;
            Unity_Add_float3(_Add_2e17f38cc40047c99d154ef26fb887e3_Out_2_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_OUT_5_Vector3, _Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3);
            float _Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float = _WaveSteepness3;
            float _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float = _WaveLength3;
            float3 _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3 = _WaveDirection3;
            float _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float = _ActualTime;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            float3 _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3;
            CalculatePosition_float(_Property_b5ee5b2505464b8690f950133c99e843_Out_0_Float, _Property_7c6180e0b7a44021ac317ea3c38e3677_Out_0_Float, _Property_1cf27c4199844aacae3b3d2d846d2c79_Out_0_Vector3, IN.WorldSpacePosition, _Property_2d6c55f97bdf4ff89ef28492ffe7c462_Out_0_Float, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_TAN_8_Vector3, _CalculatePositionCustomFunction_c3f53ba8bb464e8c8bfe23f57d923cfb_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3);
            float3 _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            Unity_Add_float3(_Add_323eb3a1a94b4b69857d181c479807e5_Out_2_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_OUT_5_Vector3, _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3);
            float3 _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3;
            Unity_CrossProduct_float(_CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_BIN_9_Vector3, _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3, _CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3);
            float3 _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            Unity_Normalize_float3(_CrossProduct_c4f49a8d3c6a4c969412806738ab1d9d_Out_2_Vector3, _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3);
            description.Position = _Add_f8a40109dae7467181bcc25f170b2c16_Out_2_Vector3;
            description.Normal = _Normalize_45ebee2a95bb41e4b0d95b44737e9739_Out_1_Vector3;
            description.Tangent = _CalculatePositionCustomFunction_f75f8a27172840c5a3167b4adf3be3a1_TAN_8_Vector3;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4 = _ShallowWaterColor;
            float4 _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float);
            float _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_ab950879f46446ab87394dcb0051d813_Out_1_Float, _ProjectionParams.z, _Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float);
            float4 _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_R_1_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[0];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_G_2_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[1];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_B_3_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[2];
            float _Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float = _ScreenPosition_72da18ed73eb4fe5b8248f1feee90fbb_Out_0_Vector4[3];
            float _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float = _Depth;
            float _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float;
            Unity_Add_float(_Split_3be5c3f8d1904cd2952c99a7ae883555_A_4_Float, _Property_04cd59929f86477281f9d6b1a0e4342c_Out_0_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float);
            float _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float;
            Unity_Subtract_float(_Multiply_b5bf7a3f7cf145199c49a6bbee802e1a_Out_2_Float, _Add_77721b70b7dc44c09548030c708cebf4_Out_2_Float, _Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float);
            float _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float = _Strength;
            float _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_3914e7c4f51f4a639cff6f57cdb0a4f7_Out_2_Float, _Property_8023bf0ccbbc47d08fc97e22b3aef572_Out_0_Float, _Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float);
            float _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float;
            Unity_Clamp_float(_Multiply_09b3088fa6cf481db71d05ac9dc9f9ab_Out_2_Float, 0, 1, _Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float);
            float4 _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4;
            Unity_Lerp_float4(_Property_1ffb00b107fd44059facef6d828c38fc_Out_0_Vector4, _Property_87774744233b432fac31228c82ca0c2c_Out_0_Vector4, (_Clamp_bd54a1d7bce44eef98553640eba7a802_Out_3_Float.xxxx), _Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4);
            float4 _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FoamColor) : _FoamColor;
            float _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float);
            float _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_b0af04ebabc34f0aacd66de4f90ac15b_Out_1_Float, _ProjectionParams.z, _Multiply_0842fa15872b40678e800db729b00908_Out_2_Float);
            float4 _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_f65f59f489f64ee888024c54d0ce44d8_R_1_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[0];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_G_2_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[1];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_B_3_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[2];
            float _Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float = _ScreenPosition_e375e8ab67064da6807da4435ff7cbf0_Out_0_Vector4[3];
            float _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float = _FoamDepth;
            float _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float;
            Unity_Add_float(_Split_f65f59f489f64ee888024c54d0ce44d8_A_4_Float, _Property_65dd981bf08a4567bbb93fbfb3af829e_Out_0_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float);
            float _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float;
            Unity_Subtract_float(_Multiply_0842fa15872b40678e800db729b00908_Out_2_Float, _Add_35081083200f49f1b6b309d48f3e28a5_Out_2_Float, _Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float);
            float _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float = _FoamStrength;
            float _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_7890e454078c4d1dba6c73ce3c4aa37d_Out_2_Float, _Property_2095217ca14c4e96b121a45e6a600a5d_Out_0_Float, _Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float);
            float _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float = _FoamSpeed;
            float _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9172697e8e94492d8f4f34063967e7a3_Out_0_Float, _Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float);
            float2 _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_ed2cd53c98d6455a9300db4ebd03a746_Out_2_Float.xx), _TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2);
            float _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float = _foamSize;
            float _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_b1c4820b4efc46eeb540ab2062ba455a_Out_3_Vector2, _Property_afc06dae47a94f51bcf98af1cc034694_Out_0_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float);
            float _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float;
            Unity_Step_float(_Multiply_136f44d645e6466b8b2523f1ce786b30_Out_2_Float, _GradientNoise_a4ab9e7550bd425ea5766a66ee444806_Out_2_Float, _Step_a521d8395f7842529b00669ed29532ab_Out_2_Float);
            float4 _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_f67205ac0b134de58ca0736acd43fafe_Out_3_Vector4, _Property_63acd2b66ad0442e873e08e755083fd3_Out_0_Vector4, (_Step_a521d8395f7842529b00669ed29532ab_Out_2_Float.xxxx), _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4);
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_R_1_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[0];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_G_2_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[1];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_B_3_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[2];
            float _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float = _Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4[3];
            surface.BaseColor = (_Lerp_b1dd83f71ed74a119ecd665eb75d5cdf_Out_3_Vector4.xyz);
            surface.Alpha = _Split_cdf55f5480bc4a4dba2c1dea8d4d6de6_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}