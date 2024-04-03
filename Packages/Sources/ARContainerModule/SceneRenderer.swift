// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ARKit
import Foundation
import RealityKit
import SharedModels

enum RendererError: Error {
    case objectResolutionError
}

public struct SceneRenderer: Equatable {
    public var arView: ARView

    public func drawScene(
        scenes: [LayersScene]
    ) throws {
        let anchors = scenes.flatMap { $0.anchors }

        arView.scene.anchors.forEach { anchor in
            if !anchors.contains(where: { $0.id.uuidString == anchor.name }) {
                arView.scene.removeAnchor(anchor)
            }
        }

        for anchor in anchors {
            let existingEntity = arView.scene.findEntity(named: anchor.id.uuidString)

            if existingEntity == nil,
               let anchorEntity = try? resolveEntity(anchor) as? AnchorEntity
            {
                anchorEntity.name = anchor.id.uuidString
                arView.scene.addAnchor(anchorEntity)
            }

            guard let anchorEntity = existingEntity as? AnchorEntity else {
                return
            }

            try updateEntityChildren(
                prevChildren: anchorEntity.children,
                nextChildren: anchor.children
            )
        }
    }

    private func resolveEntity(
        _ entity: any LayersEntity
    ) throws -> RealityKit.Entity {
        if let layersAnchor = entity as? LayersAnchor {
            var translation = matrix_identity_float4x4

            translation.columns.3.x = layersAnchor.position.x
            translation.columns.3.y = layersAnchor.position.y
            translation.columns.3.z = layersAnchor.position.z

            let transform = arView.cameraTransform.matrix

            let rotation = matrix_float4x4(SCNMatrix4MakeRotation(Float.pi / 2, 0, 0, 1))

            let anchorTransform = matrix_multiply(transform, matrix_multiply(translation, rotation))

            let anchor = AnchorEntity(world: anchorTransform)

            try layersAnchor.children.forEach { child in
                try anchor.addChild(
                    resolveEntity(child)
                )
            }

            return anchor
        }

        if let model = entity as? LayersModel {
            let mesh = try resolveMesh(model.mesh)

            let materials = try resolveMaterials(model.materials)

            let modelEntity = ModelEntity(
                mesh: mesh,
                materials: materials
            )

            modelEntity.name = model.id.uuidString

            modelEntity.setOrientation(
                simd_quatf(angle: -.pi / 2, axis: [0, 0, 1]),
                relativeTo: nil
            )

            return modelEntity
        }

        throw RendererError.objectResolutionError
    }

    private func resolveMesh(
        _ entity: any LayersEntity
    ) throws -> MeshResource {
        if let box = entity as? LayersBox {
            let mesh = MeshResource.generateBox(
                size: box.size,
                cornerRadius: box.cornerRadius
            )

            return mesh
        }

        if let text = entity as? LayersText {
            let mesh = MeshResource.generateText(
                text.text,
                extrusionDepth: text.extrusionDepth,
                font: .init(
                    descriptor: .init(
                        name: text.font.name, size: CGFloat(text.font.size)
                    ),
                    size: CGFloat(text.font.size)
                ),
                containerFrame: .zero,
                alignment: resolveTextAlignment(text.alignment),
                lineBreakMode: resolveTextLineBreakMode(text.lineBreakMode)
            )

            return mesh
        }

        throw RendererError.objectResolutionError
    }

    private func resolveMaterials(
        _ materials: [any LayersMaterial]
    ) throws -> [Material] {
        return try materials.map { material in
            if let material = material as? LayersSimpleMaterial {
                return SimpleMaterial(
                    color: resolveColor(material.color),
                    roughness: MaterialScalarParameter(floatLiteral: material.roughness),
                    isMetallic: material.metallic
                )
            }

            throw RendererError.objectResolutionError
        }
    }

    func resolveColor(_ color: LayersRGBAColor) -> UIColor {
        return UIColor(
            red: CGFloat(color.red),
            green: CGFloat(color.green),
            blue: CGFloat(color.blue),
            alpha: CGFloat(color.alpha)
        )
    }

    func resolveTextAlignment(
        _ textAlignment: LayersTextAlignment
    ) -> CTTextAlignment {
        switch textAlignment {
        case .center:
            return .center
        }
    }

    func resolveTextLineBreakMode(
        _ lineBreakMode: LayersTextLineBreakMode
    ) -> CTLineBreakMode {
        switch lineBreakMode {
        case .byWordWrapping:
            return .byWordWrapping
        }
    }

    func updateEntityChildren(
        prevChildren: Entity.ChildCollection,
        nextChildren: [any LayersEntity]
    ) throws {
        if prevChildren.isEmpty, nextChildren.isEmpty {
            return
        }

        for childEntity in prevChildren {
            guard let child = nextChildren.first(
                where: { $0.id.uuidString == childEntity.name }
            ) else {
                return
            }

            if let modelEntity = childEntity as? ModelEntity,
               let model = child as? LayersModel
            {
                modelEntity.model?.mesh = try resolveMesh(model.mesh)
                modelEntity.model?.materials = try resolveMaterials(model.materials)
            }

            try updateEntityChildren(
                prevChildren: childEntity.children,
                nextChildren: child.children
            )
        }
    }
}
