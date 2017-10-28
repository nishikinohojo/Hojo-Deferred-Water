using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using System;
using UnityEngine.Timeline;

namespace HojoSystem
{

	public class HojoDeferredWaterByMeshRenderer : MonoBehaviour
	{
		[SerializeField]
		private MeshRenderer waterRenderer;

		[SerializeField]
		private Camera targetCamera;

		[SerializeField]
		private Material waterMaterial;

		private CommandBuffer commandBuffer;

		private void Awake ()
		{

			var filter = waterRenderer.GetComponent<MeshFilter> ();
			if (filter == null) {
				throw new Exception ("No Mesh Filter.");
			}
			//メッシュを取得するためだけに使っている
			waterRenderer.enabled = false;

			var mesh = filter.mesh;
			var matrix = Matrix4x4.TRS (filter.transform.position, filter.transform.rotation, filter.transform.localScale);
			this.commandBuffer = new HojoDeferredWaterCommandDispatcher (mesh, matrix, waterMaterial).PublishCommandBuffer (this.targetCamera);

		}

		private void OnDestroy ()
		{
			if (commandBuffer != null) {
				targetCamera.RemoveCommandBuffer (CameraEvent.AfterGBuffer, commandBuffer);
			}
		}


	}

}