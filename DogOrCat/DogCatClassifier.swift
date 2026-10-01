// Created by Prof. H in 2025
// Part of the DogOrCat project
// Using Swift 6.0
// Qapla'

// ============================================================
// TEACHING NOTES: DogCatClassifier.swift
// ------------------------------------------------------------
// This file wraps a Core ML model (DogCat.mlmodel) so the rest
// of the app can classify a UIImage with a single method call.
//
// Three Apple frameworks work together here:
//   • CoreML  – runs the trained machine learning model.
//   • Vision  – prepares images for ML models and standardizes
//               the results (scaling, cropping, color format).
//   • UIKit   – provides the UIImage type used as input.
//
// The flow is:
//   UIImage → CIImage → VNImageRequestHandler → VNCoreMLRequest
//   → VNClassificationObservation → completion(label)
// ============================================================

import CoreML
import Vision
import UIKit

class DogCatClassifier {
    // The Vision-wrapped ML model. `VNCoreMLModel` is Vision's
    // adapter around a raw Core ML model — it lets Vision handle
    // the image preprocessing the model expects.
    private let model: VNCoreMLModel

    // Failable initializer (note the `init?`). Loading a model
    // can fail (e.g., the .mlmodel file is missing or corrupt),
    // so we return nil instead of crashing. `DogCat()` is the
    // Swift class Xcode auto-generates from DogCat.mlmodel.
    init?() {
        guard let model = try? VNCoreMLModel(for: DogCat().model) else {
            return nil
        }
        self.model = model
    }

    // Classifies an image asynchronously. We use a completion
    // handler (a closure called when work finishes) because ML
    // inference should NOT block the main/UI thread.
    // `@escaping` means the closure may be called AFTER this
    // function returns — required for async work.
    func classify(image: UIImage, completion: @escaping (String?) -> Void) {
        // Vision works with CIImage (Core Image), not UIImage,
        // so we convert. If conversion fails, report no result.
        guard let ciImage = CIImage(image: image) else {
            completion(nil)
            return
        }

        // Build the ML request. The trailing closure runs once
        // Vision finishes running the model on the image.
        let request = VNCoreMLRequest(model: model) { request, error in
            // Classification models return an array of
            // VNClassificationObservation, sorted by confidence
            // (highest first). We just want the top guess.
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                completion(nil)
                return
            }

            print("Confidence is: \(topResult.confidence * 100)%")

            // Confidence is a Float from 0.0 to 1.0. We require
            // 90%+ certainty before trusting the label; otherwise
            // we return "NOT SURE" so the UI can be honest with
            // the user instead of guessing wildly.
            if topResult.confidence > 0.9 {
                completion(topResult.identifier)
            } else {
                completion("NOT SURE")
            }
        }

        // The handler owns the image and executes the request.
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])

        // Run inference off the main thread so the UI stays
        // responsive. `.userInitiated` = high priority because
        // the user is actively waiting on this result.
        // NOTE: The completion above will fire on this background
        // thread — the caller (ContentView) is responsible for
        // hopping back to the main thread before updating UI.
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
