//
//  ContentView.swift
//  DinoAR
//
//  Created by Dinuka Dissanayake on 5/9/24.
//

import SwiftUI
import RealityKit
import AVFoundation

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    private let backgroundSoundURL = Bundle.main.url(forResource: "background_sound", withExtension: "mp3")!
    private var backgroundSoundPlayer: AVAudioPlayer?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)

        // Load and position dinosaurs on a horizontal plane
        loadAndPositionDinosaur(named: "dinosaur_animation.usdz", at: [0.0, 0.0, -0.5], scale: SIMD3<Float>(0.005, 0.005, 0.005), in: arView)
        loadAndPositionDinosaur(named: "Pteradactal.usdz", at: [0.2, 0.5, -0.5], scale: SIMD3<Float>(0.005, 0.005, 0.005), in: arView)
        loadAndPositionDinosaur(named: "Dinosaur.usdz", at: [-0.2, 0.0, -0.5], scale: SIMD3<Float>(0.005, 0.005, 0.005), in: arView)
        loadAndPositionDinosaur(named: "oaktrees.usdz", at: [2, 0.0, -0.5], scale: SIMD3<Float>(0.005, 0.005, 0.005), in: arView)
        loadAndPositionDinosaur(named: "rock.usdz", at: [-1.5, 0.0, -0.5], scale: SIMD3<Float>(0.001, 0.001, 0.001), in: arView)


        // Play background sound
        context.coordinator.playBackgroundSound()
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    private func loadAndPositionDinosaur(named filename: String, at position: SIMD3<Float>, scale: SIMD3<Float>, in arView: ARView) {
        // Load dinosaur model
        let dinosaur = try! ModelEntity.loadModel(named: filename)
        
        // Position dinosaur on a horizontal plane
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2])
        anchor.addChild(dinosaur)
        dinosaur.setScale(scale, relativeTo: nil)
        dinosaur.position = position
        
        // Check if the model has animations
        if dinosaur.availableAnimations.count > 0 {
            // If animations are available, play the first one
            dinosaur.playAnimation(dinosaur.availableAnimations[0].repeat(duration: .infinity), transitionDuration: 0.25)
        }
        
        // Add anchor to the scene
        arView.scene.addAnchor(anchor)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func playBackgroundSound() {
            do {
                parent.backgroundSoundPlayer = try AVAudioPlayer(contentsOf: parent.backgroundSoundURL)
                parent.backgroundSoundPlayer?.numberOfLoops = -1 // Infinite loop
                parent.backgroundSoundPlayer?.play()
            } catch {
                print("Error playing background sound: \(error.localizedDescription)")
            }
        }
    }
    
}

#Preview {
    ContentView()
}
