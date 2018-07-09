#line 1

////////////////////////////////////////////////////////////////////////////////
// Resource/Renderer/Deferred/Base.vert.glsl
//
// This file is a part of ItsyScape.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
///////////////////////////////////////////////////////////////////////////////

attribute vec3 VertexNormal;
attribute vec2 VertexTexture;

uniform mat4 scape_WorldMatrix;
uniform mat4 scape_NormalMatrix;

varying vec3 frag_Position;
varying vec3 frag_Normal;
varying vec4 frag_Color;
varying vec2 frag_Texture;

void performTransform(
	mat4 modelViewProjection,
	vec4 vertexPosition,
	out vec3 localPosition,
	out vec4 projectedPosition);

vec4 position(mat4 modelViewProjection, vec4 vertexPosition)
{
	vec3 localPosition = vec3(0);
	vec4 projectedPosition = vec4(0);
	performTransform(
		modelViewProjection,
		vertexPosition,
		localPosition,
		projectedPosition);

	frag_Position = (scape_WorldMatrix * vec4(localPosition, 1)).xyz;
	frag_Normal = normalize(mat3(scape_NormalMatrix) * VertexNormal);
	frag_Color = VertexColor;
	frag_Texture = VertexTexture;

	return projectedPosition;
}
