using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
public class TorusGenerator : MonoBehaviour
{
    public float tubeRadius = 0.5f;
    public float torusRadius = 2f;
    public int tubeSegments = 24;
    public int torusSegments = 18;

    void Start()
    {
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        meshFilter.mesh = CreateTorusMesh(tubeRadius, torusRadius, tubeSegments, torusSegments);
    }

    Mesh CreateTorusMesh(float tubeRadius, float torusRadius, int tubeSegments, int torusSegments)
    {
        Mesh mesh = new Mesh();

        int vertexCount = tubeSegments * torusSegments;
        Vector3[] vertices = new Vector3[vertexCount];
        Vector2[] uv = new Vector2[vertexCount];
        int[] triangles = new int[tubeSegments * torusSegments * 6];

        for (int ts = 0; ts < torusSegments; ts++)
        {
            for (int bs = 0; bs < tubeSegments; bs++)
            {
                int i = ts * tubeSegments + bs;

                // Angle around torus
                float theta = (float)ts / torusSegments * Mathf.PI * 2;
                // Angle around tube
                float phi = (float)bs / tubeSegments * Mathf.PI * 2;

                float x = (torusRadius + tubeRadius * Mathf.Cos(phi)) * Mathf.Cos(theta);
                float y = (torusRadius + tubeRadius * Mathf.Cos(phi)) * Mathf.Sin(theta);
                float z = tubeRadius * Mathf.Sin(phi);

                vertices[i] = new Vector3(x, y, z);
                uv[i] = new Vector2((float)ts / torusSegments, (float)bs / tubeSegments);

                // Setup triangles
                int current = ts * tubeSegments + bs;
                int next = ts * tubeSegments + ((bs + 1) % tubeSegments);
                int nextSegment = ((ts + 1) % torusSegments) * tubeSegments + bs;
                int nextSegmentNext = ((ts + 1) % torusSegments) * tubeSegments + ((bs + 1) % tubeSegments);

                int triangleIndex = (ts * tubeSegments + bs) * 6;
                triangles[triangleIndex] = current;
                triangles[triangleIndex + 1] = next;
                triangles[triangleIndex + 2] = nextSegment;
                triangles[triangleIndex + 3] = nextSegment;
                triangles[triangleIndex + 4] = next;
                triangles[triangleIndex + 5] = nextSegmentNext;
            }
        }

        mesh.vertices = vertices;
        mesh.uv = uv;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();

        return mesh;
    }
}