//
//  ContentView.swift
//  DinoAR
//
//  Created by Dinuka Dissanayake on 5/9/24.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)

//        // Create a cube model
//        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
//        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
//        let model = ModelEntity(mesh: mesh, materials: [material])
//        model.transform.translation.y = 0.05
//
//        // Create horizontal plane anchor for the content
//        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
//        anchor.children.append(model)
//


        // Load and position dinosaurs on a horizontal plane
        loadAndPositionDinosaur(named: "dinosaur_animation.usdz", at: [0.0, 0.0, -0.5], in: arView)
        loadAndPositionDinosaur(named: "Pteradactal.usdz", at: [0.2, 0.0, -0.5], in: arView)
//        loadAndPositionDinosaur(named: "dinosaur3.usdz", at: [-0.2, 0.0, -0.5], in: arView)


        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    private func loadAndPositionDinosaur(named filename: String, at position: SIMD3<Float>, in arView: ARView) {
        // Load dinosaur model
        let dinosaur = try! ModelEntity.loadModel(named: filename)
        
        // Position dinosaur on a horizontal plane
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2])
        anchor.addChild(dinosaur)
        dinosaur.setScale(SIMD3<Float>(0.005, 0.005, 0.005), relativeTo: nil)
        dinosaur.position = position
        
        // Check if the model has animations
        if let animations = dinosaur.availableAnimations, !animations.isEmpty {
            // If animations are available, play the first one
            dinosaur.playAnimation(animations[0].repeat(duration: .infinity), transitionDuration: 0.25)
        }
        
        // Add anchor to the scene
        arView.scene.addAnchor(anchor)
    }
    
}

#Preview {
    ContentView()
}
