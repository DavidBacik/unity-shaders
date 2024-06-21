using UnityEngine;
using UnityEngine.UI;

namespace Testing.CustomImage
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(CanvasRenderer))]
    public class SquareImage : MaskableGraphic
    {
        public int divisionsX = 2; // Number of subdivisions along the X axis
        public int divisionsY = 2; // Number of subdivisions along the Y axis
        
        protected override void OnPopulateMesh(VertexHelper vh)
        {
            base.OnPopulateMesh(vh);
            vh.Clear();

            float width = rectTransform.rect.width;
            float height = rectTransform.rect.height;

            // Step to move on each axis
            float stepX = width / divisionsX;
            float stepY = height / divisionsY;

            // Create vertices
            for (int y = 0; y <= divisionsY; y++)
            {
                for (int x = 0; x <= divisionsX; x++)
                {
                    Vector2 position = new Vector2(x * stepX, y * stepY) - new Vector2(width / 2, height / 2); // Centering the mesh
                    vh.AddVert(position, color, new Vector2(x / (float)divisionsX, y / (float)divisionsY));
                }
            }

            // Create triangles
            for (int y = 0; y < divisionsY; y++)
            {
                for (int x = 0; x < divisionsX; x++)
                {
                    int startIndex = (divisionsX + 1) * y + x;
                    vh.AddTriangle(startIndex, startIndex + 1, startIndex + divisionsX + 1);
                    vh.AddTriangle(startIndex + divisionsX + 1, startIndex + 1, startIndex + divisionsX + 2);
                }
            }
        }

    }
}