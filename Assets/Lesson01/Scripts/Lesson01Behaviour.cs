using System.Collections.Generic;
using UnityEngine;

public class Lesson01Behaviour : MonoBehaviour
{
	[SerializeField] private MeshFilter _mesh;
    
	private float radius = 1f;
	private int segments = 36;

	
	void Start()
	{
		GenerateMesh(_mesh.mesh);
	}
	
	private void GenerateMesh(Mesh mesh)
	{
		List<Vector3> vertices = new();
		List<Vector3> normals  = new();
		List<int>     indices  = new();
		
		vertices.Add(new Vector3(-1, 0, -1));
		vertices.Add(new Vector3(-1, 0,  1));
		vertices.Add(new Vector3( 1, 0,  1));
		vertices.Add(new Vector3( 1, 0, -1));
		
		normals.Add(new Vector3(0, 1, 0));
		normals.Add(new Vector3(0, 1, 0));
		normals.Add(new Vector3(0, 1, 0));
		normals.Add(new Vector3(0, 1, 0));
		
		indices.Add(0);
		indices.Add(1);
		indices.Add(2);
		
		indices.Add(0);
		indices.Add(2);
		indices.Add(3);
		
		mesh.Clear();
		mesh.SetVertices(vertices);
		mesh.SetNormals(normals);
		mesh.SetIndices(indices, MeshTopology.Triangles, 0);
	}
}