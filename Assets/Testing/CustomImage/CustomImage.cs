using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
[RequireComponent(typeof(CanvasRenderer))]
public class CustomImage : MaskableGraphic
{
    [SerializeField]private float _cornerRadius = 10f;
    [SerializeField]private int   _cornerSegments = 10;
    
    private float _width;
    private float _height;
    
    protected override void OnPopulateMesh(VertexHelper vh)
    {
        RectTransform rt = GetComponent<RectTransform>();
        _width = rt.rect.width;
        _height = rt.rect.height;
        
        vh.Clear();
        List<Vector2> points = new List<Vector2>();

        // Generate points for each corner
        AddCornerArc(points, new Vector2(-_width / 2 + _cornerRadius, -_height / 2 + _cornerRadius), 180, _cornerRadius, _cornerSegments); // Bottom left
        AddCornerArc(points, new Vector2(_width / 2 - _cornerRadius, -_height / 2 + _cornerRadius), 270, _cornerRadius, _cornerSegments); // Bottom right
        AddCornerArc(points, new Vector2(_width / 2 - _cornerRadius, _height / 2 - _cornerRadius), 0, _cornerRadius, _cornerSegments); // Top right
        AddCornerArc(points, new Vector2(-_width / 2 + _cornerRadius, _height / 2 - _cornerRadius), 90, _cornerRadius, _cornerSegments); // Top left

        // Calculate UVs for a simple mapping based on vertex positions within the bounding box
        float x = -_width / 2;
        float y = -_height / 2;

        // Create triangles
        vh.AddVert(new Vector3(0, 0), color, new Vector2(0.5f, 0.5f)); // Center vertex
        for (int i = 0; i < points.Count; i++)
        {
            Vector2 point = points[i];
            // Map the point to UV space
            float u = (point.x - x) / (_width);
            float v = (point.y - y) / (_height);
            vh.AddVert(point, color, new Vector2(u, v)); // Map vertices to UV based on their position

            if (i > 0)
            {
                vh.AddTriangle(0, i, i + 1);
            }
        }
        
        vh.AddTriangle(0, points.Count, 1); // Last triangle to connect back to the start
    }
    
    private void AddCornerArc(List<Vector2> points, Vector2 center, float startAngle, float radius, int segments)
    {
        float angle = startAngle;
        float angleStep = 90.0f / segments;
    
        for (int i = 0; i <= segments; i++)
        {
            float radian = angle * Mathf.Deg2Rad;
            points.Add(new Vector2(center.x + Mathf.Cos(radian) * radius, center.y + Mathf.Sin(radian) * radius));
            angle += angleStep;
        }
    }

    // protected override void OnPopulateMesh(VertexHelper vh)
    // {
    //     Vector2 corner1 = Vector2.zero;
    //     Vector2 corner2 = Vector2.zero;
    //
    //     corner1.x = 0f;
    //     corner1.y = 0f;
    //     corner2.x = 1f;
    //     corner2.y = 1f;
    //
    //     corner1.x -= rectTransform.pivot.x;
    //     corner1.y -= rectTransform.pivot.y;
    //     corner2.x -= rectTransform.pivot.x;
    //     corner2.y -= rectTransform.pivot.y;
    //
    //     corner1.x *= rectTransform.rect.width;
    //     corner1.y *= rectTransform.rect.height;
    //     corner2.x *= rectTransform.rect.width;
    //     corner2.y *= rectTransform.rect.height;
    //
    //     vh.Clear();
    //
    //     UIVertex vert = UIVertex.simpleVert;
    //
    //     vert.position = new Vector2(corner1.x, corner1.y);
    //     vert.color = color;
    //     vert.uv0 = new Vector2(0, 0); // Bottom-left
    //     vh.AddVert(vert);
    //
    //     vert.position = new Vector2(corner1.x, corner2.y);
    //     vert.color = color;
    //     vert.uv0 = new Vector2(0, 1); // Top-left
    //     vh.AddVert(vert);
    //
    //     vert.position = new Vector2(corner2.x, corner2.y);
    //     vert.color = color;
    //     vert.uv0 = new Vector2(1, 1); // Top-right
    //     vh.AddVert(vert);
    //
    //     vert.position = new Vector2(corner2.x, corner1.y);
    //     vert.color = color;
    //     vert.uv0 = new Vector2(1, 0); // Bottom-right
    //     vh.AddVert(vert);
    //
    //     vh.AddTriangle(0, 1, 2);
    //     vh.AddTriangle(2, 3, 0);
    // }
}