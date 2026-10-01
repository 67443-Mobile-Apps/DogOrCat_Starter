// Created by Prof. H in 2025
// Part of the DogOrCat project
// Using Swift 6.0
// Qapla'

// ============================================================
// TEACHING NOTES: ImagePicker.swift
// ------------------------------------------------------------
// SwiftUI does not (yet) have a built-in camera view, but UIKit
// does: `UIImagePickerController`. This file bridges that older
// UIKit view controller into SwiftUI using the
// `UIViewControllerRepresentable` protocol.
//
// The pattern has three parts:
//   1. A SwiftUI struct that conforms to
//      UIViewControllerRepresentable (this is ImagePicker).
//   2. `makeUIViewController` — creates the UIKit controller.
//   3. A Coordinator class — acts as the UIKit delegate and
//      passes events back into SwiftUI.
//
// Data flows OUT of the picker via an @Binding, so the parent
// SwiftUI view (ContentView) receives the captured image.
// ============================================================

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    // @Binding = a two-way reference to state OWNED by the
    // parent view. When we assign to `image` here, the parent's
    // @State variable updates and SwiftUI re-renders.
    @Binding var image: UIImage?

    // Pulls SwiftUI's dismiss action from the environment so
    // we can close the sheet from inside the coordinator.
    @Environment(\.dismiss) private var dismiss

    // Called once when the SwiftUI view appears. We build and
    // configure the UIKit view controller here.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera            // Use the camera (not the photo library)
        picker.delegate = context.coordinator  // Route callbacks to our Coordinator
        return picker
    }

    // Called whenever SwiftUI state changes and the view may
    // need updating. Nothing to sync here — the picker is
    // one-shot — so this is intentionally empty.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    // SwiftUI calls this once to build the coordinator. The
    // coordinator lives as long as the ImagePicker does and
    // acts as the "glue" between UIKit's delegate world and
    // SwiftUI's declarative world.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // ------------------------------------------------------
    // Coordinator: the UIKit delegate.
    // UIImagePickerController reports events (photo taken,
    // user cancelled) via a delegate protocol. SwiftUI structs
    // cannot be delegates (they're value types and delegates
    // must be NSObject subclasses), so we use a nested class.
    // ------------------------------------------------------
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        // Reference back to the SwiftUI wrapper so we can
        // reach its @Binding and dismiss action.
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // Called by UIKit when the user snaps a photo. The
        // `info` dictionary contains the image under the
        // `.originalImage` key. We write it into the parent's
        // binding — which updates ContentView's state — then
        // dismiss the sheet.
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        // Called if the user taps Cancel. Just close the sheet.
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
