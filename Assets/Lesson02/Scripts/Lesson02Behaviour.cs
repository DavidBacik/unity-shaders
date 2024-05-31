using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;

public class Lesson02Behaviour : MonoBehaviour
{
	[SerializeField] private MeshRenderer _renderer;
	[SerializeField] private MeshFilter   _mesh;
	[SerializeField] private int          _majorSegments = 32;
	[SerializeField] private float        _majorRadius   = 4f;
	[SerializeField] private int          _minorSegments = 16;
	[SerializeField] private float        _minorRadius   = 1f;

	[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
	private struct Vertex
	{
		public Vector3 Position;
		public Vector3 Normal;
	}

	void Start()
	{
		GenerateMesh(_mesh.mesh);
	}
	
	private void GenerateMesh(Mesh mesh)
	{
		mesh.Clear();
		
		// vertex buffer
		VertexAttributeDescriptor[] layout = new[]
		                                   {
			                                   new VertexAttributeDescriptor(VertexAttribute.Position, VertexAttributeFormat.Float32, 3),
			                                   new VertexAttributeDescriptor(VertexAttribute.Normal, VertexAttributeFormat.Float32, 3)
		                                   };

		int vertexCount = _majorSegments * _minorSegments;

		NativeArray<Vertex> vertices = new (vertexCount, Allocator.Temp);
		int                 index    = 0;
		for (int majorSegment = 0; majorSegment < _majorSegments; ++majorSegment)
		{
			float majorSegmentAngle = Mathf.PI * 2f * majorSegment / _majorSegments;
			
			for (int minorSegment = 0; minorSegment < _minorSegments; ++minorSegment)
			{
				float minorSegmentAngle = Mathf.PI * 2f * minorSegment / _minorSegments;

				Vector3 ringCenter = new(
					Mathf.Cos(majorSegmentAngle) * _majorRadius,
					0f,
					Mathf.Sin(majorSegmentAngle) * _majorRadius
				);
				
				Vector3 position = new(
					Mathf.Cos(majorSegmentAngle) * (_majorRadius + Mathf.Cos(minorSegmentAngle) * _minorRadius),
					Mathf.Sin(minorSegmentAngle) * _minorRadius,
					Mathf.Sin(majorSegmentAngle) * (_majorRadius + Mathf.Cos(minorSegmentAngle) * _minorRadius)
				);
				
				vertices[index++] = new Vertex
				                    {
					                    Position = position,
					                    Normal = (position - ringCenter).normalized
				                    };
			}
		}

		mesh.SetVertexBufferParams(vertexCount, layout);
		mesh.SetVertexBufferData(vertices, 0, 0, vertexCount);

		// index buffer
		int                 indexCount = _majorSegments * _minorSegments * 2 * 3;
		NativeArray<ushort> indices    = new(indexCount, Allocator.Temp);
		
		index    = 0;
		for (int majorSegment = 0; majorSegment < _majorSegments; ++majorSegment)
		{
			int nextMajorSegment = (majorSegment + 1) % _majorSegments;
			
			for (int minorSegment = 0; minorSegment < _minorSegments; ++minorSegment)
			{
				int nextMinorSegment = (minorSegment + 1) % _minorSegments;
				
				int index00 = majorSegment     * _minorSegments + minorSegment;
				int index01 = majorSegment     * _minorSegments + nextMinorSegment;
				int index10 = nextMajorSegment * _minorSegments + minorSegment;
				int index11 = nextMajorSegment * _minorSegments + nextMinorSegment;
				
				// first triangle
				indices[index++] = (ushort)index00;
				indices[index++] = (ushort)index01;
				indices[index++] = (ushort)index11;

				// second triangle
				indices[index++] = (ushort)index00;
				indices[index++] = (ushort)index11;
				indices[index++] = (ushort)index10;
			}
		}

		mesh.SetIndexBufferParams(indexCount, IndexFormat.UInt16);
		mesh.SetIndexBufferData(indices, 0, 0, indexCount);
		
		// submesh
		mesh.subMeshCount = 1;
		mesh.SetSubMesh(0, new SubMeshDescriptor(0, indexCount, MeshTopology.Triangles));

		mesh.RecalculateBounds();
	}
}