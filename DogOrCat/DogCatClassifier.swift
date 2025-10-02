// Created by Prof. H in 2025
// Part of the DogOrCat project
// Using Swift 6.0
// Qapla'

import CoreML
import Vision
import UIKit

class DogCatClassifier {
    private let model: VNCoreMLModel

    init?() {
        guard let model = try? VNCoreMLModel(for: DogCat().model) else {
            return nil
        }
        self.model = model
    }

    func classify(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(nil)
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                completion(nil)
                return
            }
          
            print("Confidence is: \(topResult.confidence * 100)%")
          
            // Only return classification if confidence is above 90%
            if topResult.confidence > 0.9 {
                completion(topResult.identifier)
            } else {
                completion("NOT SURE")
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
