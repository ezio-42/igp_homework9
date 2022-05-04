Shader "Custom/NewSurfaceShader"
{
    Properties
    {
        _MainTexture ("Texture", 2D) = "white" {}
        _DiffuseColor("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecularColor("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecularStrength("Shininess", Range(1.0, 256.0)) = 0.5
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vertex
			#pragma fragment fragment

            #include "UnityCG.cginc"

            uniform sampler2D _MainTexture;
			uniform float4 _DiffuseColor;
			uniform float4 _SpecularColor;
			uniform float _SpecularStrength;

            static const float AmbientFactor = 0.2;

            struct vertexInput
			{
				float4 Vertex : POSITION;
				float3 Normal : NORMAL;
				float2 UV : TEXCOORD0;
			};
		
			struct vertexOutput
			{
				float4 Position : SV_POSITION;
				float2 UV : TEXCOORD0;
				float3 Normal : TEXCOORD1;
				float3 ViewDirection : TEXCOORD2;
			};
		
			vertexOutput vertex(vertexInput input)
			{
				vertexOutput output;
				output.Position = UnityObjectToClipPos(input.Vertex);
				output.UV = input.UV;
				output.Normal = normalize(mul(float4(input.Normal, 0.0), unity_WorldToObject).xyz);
				output.ViewDirection = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, input.Vertex).xyz);
				return output;
			}
	
			fixed4 fragment(vertexOutput input) : COLOR
			{
				float specularIntensity = 0.0;
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 normal = normalize(input.Normal);
				float3 viewDirection = normalize(input.ViewDirection);
				float intensity = max(dot(normal, lightDirection), 0.0);
				if (intensity > 0) 
				{
					float3 h = normalize(lightDirection + viewDirection);
					specularIntensity =  pow(max(dot(normal, h), 0.0), _SpecularStrength);
				}
				fixed4 textureColor = tex2D(_MainTexture, input.UV);
				fixed4 textureTint = textureColor * _DiffuseColor;
				fixed4 ambientColor = textureTint * AmbientFactor;
				return max(textureTint*intensity + _SpecularColor*specularIntensity, ambientColor);
			}
		
			ENDCG
        }
    }
}