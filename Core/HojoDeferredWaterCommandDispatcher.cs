using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using System;
using UnityEngine.Timeline;

namespace HojoSystem
{
	public class HojoDeferredWaterCommandDispatcher
	{
		private const string DeferredWaterShaderName = "Hojo/Environment/DeferredWater";

		private const string CommandBufferName = "Hojo Deferred Water";

		private Mesh targetMesh;

		private Matrix4x4 matrix;

		private Material waterMaterial;

		public HojoDeferredWaterCommandDispatcher (Mesh targetMesh, Matrix4x4 matrix, Material waterMaterial)
		{
			if (waterMaterial.shader.name != DeferredWaterShaderName) {
				throw new Exception ("Given waterMaterial isn't DeferredWater");
			}
			this.waterMaterial = waterMaterial;
			this.targetMesh = targetMesh;
			this.matrix = matrix;
		}

		public CommandBuffer PublishCommandBuffer (Camera camera)
		{
			var commandBuffer = new CommandBuffer ();
			commandBuffer.name = CommandBufferName;
			commandBuffer.DrawMesh (targetMesh, matrix, waterMaterial);
			camera.AddCommandBuffer (CameraEvent.AfterGBuffer, commandBuffer);
			return commandBuffer;
		}
	}

}