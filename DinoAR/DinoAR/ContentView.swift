//
//  ContentView.swift
//  DinoAR
//
//  Created by Dinuka Dissanayake on 5/9/24.
//

import SwiftUI
import RealityKit
import ARKit
import AVFoundation

struct ContentView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    private let backgroundSoundURL = Bundle.main.url(forResource: "background_sound", withExtension: "mp3")!
    private var backgroundSoundPlayer: AVAudioPlayer?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Set up AR session with image tracking configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
            configuration.trackingImages = referenceImages
            configuration.maximumNumberOfTrackedImages = 3
        } else {
            print("Error: No reference images found.")
        }
        
        arView.session.delegate = context.coordinator
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        
        // Pass the arView to the coordinator
        context.coordinator.arView = arView
        
        // Play background sound
        context.coordinator.playBackgroundSound()
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        weak var arView: ARView?
        var isModelDisplayed = false
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let arView = arView else { return }

            for anchor in anchors {
                if let imageAnchor = anchor as? ARImageAnchor {
                    print("Marker detected: \(imageAnchor.referenceImage.name ?? "unknown")")
                    switch imageAnchor.referenceImage.name {
                    case "marker1":
                        // Load and position models for Marker1
                        self.loadAndPositionDinosaur(named: "Dinosaur.usdz", at: [-2.5, -0.2, -2], scale: SIMD3<Float>(0.005, 0.005, 0.005), relativeTo: imageAnchor, in: arView)
                        self.loadAndPositionDinosaur(named: "rock.usdz", at: [-6, -0.2, -4], scale: SIMD3<Float>(0.005, 0.005, 0.005), relativeTo: imageAnchor, in: arView)
                    case "marker2":
                        // Load and position models for Marker2
                        self.loadAndPositionDinosaur(named: "dinosaur_animation.usdz", at: [0.0, -0.2, -2], scale: SIMD3<Float>(0.005, 0.005, 0.005), relativeTo: imageAnchor, in: arView)
                    case "marker3":
                        // Load and position models for Marker3
                        self.loadAndPositionDinosaur(named: "oaktrees.usdz", at: [1, -0.2, -1], scale: SIMD3<Float>(0.005, 0.005, 0.005), relativeTo: imageAnchor, in: arView)
                        self.loadAndPositionDinosaur(named: "Pteradactal.usdz", at: [1, 1, -2], scale: SIMD3<Float>(0.005, 0.005, 0.005), relativeTo: imageAnchor, in: arView)
                    default:
                        print("Unknown marker detected.")
                    }
                }
            }
        }
        
        func loadAndPositionDinosaur(named filename: String, at position: SIMD3<Float>, scale: SIMD3<Float>, relativeTo imageAnchor: ARImageAnchor, in arView: ARView) {
            do {
                // Load dinosaur model
                let dinosaur = try ModelEntity.loadModel(named: filename)
                
                // Position dinosaur relative to the detected image marker
                let anchor = AnchorEntity(world: position)
                anchor.addChild(dinosaur)
                dinosaur.setScale(scale, relativeTo: nil)
                
                // Check if the model has animations
                if dinosaur.availableAnimations.count > 0 {
                    // If animations are available, play the first one
                    dinosaur.playAnimation(dinosaur.availableAnimations[0].repeat(duration: .infinity), transitionDuration: 0.25)
                }
                
                // Add anchor to the scene
                arView.scene.addAnchor(anchor)
                
                print("Dinosaur model \(filename) added to scene at position \(position).")
                
            } catch {
                print("Error loading dinosaur model \(filename): \(error.localizedDescription)")
            }
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
