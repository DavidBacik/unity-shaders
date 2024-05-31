using UnityEngine;

namespace Lesson03.Scripts
{
	public sealed class Lesson03Animation : MonoBehaviour
	{
		[SerializeField]
		private Material _material;

		void Update()
		{
			_material.SetVector(
				"_Noise",
				new Vector4(
					Mathf.Sin(Time.time)                    * 0.5f + 0.5f,
					Mathf.Sin(Time.time + 2f *Mathf.PI /3f) * 0.5f + 0.5f,
					Mathf.Sin(Time.time + 4f *Mathf.PI /3f) * 0.5f + 0.5f,
					0
				)
			);
		}
	}
}