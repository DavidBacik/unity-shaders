using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
public class CylinderGenerator : MonoBehaviour
{
    public int segments = 36;
    public float radius = 1f;
    public float height = 2f;

    void Start()
    {
        MeshFilter filter = gameObject.GetComponent<MeshFilter>();
        Mesh mesh = CreateCylinderMesh(segments, radius, height);
        filter.mesh = mesh;
    }

    Mesh CreateCylinderMesh(int segments, float radius, float height)
    {
        Mesh mesh = new Mesh();

        Vector3[] vertices = new Vector3[segments * 2];
        Vector2[] uv = new Vector2[segments * 2];
        int[] triangles = new int[segments * 6];

        float angleStep = 360.0f / segments;
        int vertexIndex = 0;
        int triangleIndex = 0;
        float uvStep = 1.0f / segments;

        // Side Circle Vertices
        for (int i = 0; i < segments; i++)
        {
            float angleInRad = Mathf.Deg2Rad * i * angleStep;
            float x = Mathf.Cos(angleInRad) * radius;
            float z = Mathf.Sin(angleInRad) * radius;

            vertices[vertexIndex] = new Vector3(x, height * 0.5f, z); // Top vertex
            vertices[vertexIndex + 1] = new Vector3(x, -height * 0.5f, z); // Bottom vertex

            // UVs
            uv[vertexIndex] = new Vector2(i * uvStep, 1); // Top UV
            uv[vertexIndex + 1] = new Vector2(i * uvStep, 0); // Bottom UV

            vertexIndex += 2;
        }

        // Creating triangles
        for (int i = 0; i < segments; i++)
        {
            int nextIndex = (i + 1) % segments;
            triangles[triangleIndex] = i * 2;
            triangles[triangleIndex + 1] = nextIndex * 2;
            triangles[triangleIndex + 2] = i * 2 + 1;

            triangles[triangleIndex + 3] = i * 2 + 1;
            triangles[triangleIndex + 4] = nextIndex * 2;
            triangles[triangleIndex + 5] = nextIndex * 2 + 1;

            triangleIndex += 6;
        }

        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uv;
        mesh.RecalculateNormals();

        return mesh;
    }
}
