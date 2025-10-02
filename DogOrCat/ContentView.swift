// Created by Prof. H in 2025
// Part of the DogOrCat project
// Using Swift 6.0
// Qapla'

import SwiftUI

struct ContentView: View {
    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    @State private var result: String?
    private let classifier = DogCatClassifier()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                if let result = result {
                    Text(result.uppercased())
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                }

                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 500)
                        .cornerRadius(10)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(maxHeight: 500)
                        .overlay(
                            Text("No photo captured")
                                .foregroundColor(.white)
                        )
                }

                Button(action: {
                    showCamera = true
                    result = nil
                }) {
                    Text("Capture Photo")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                if capturedImage != nil {
                    Button(action: classifyImage) {
                        Text("Analyze")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $capturedImage)
        }
    }

    private func classifyImage() {
        guard let image = capturedImage else { return }

        classifier?.classify(image: image) { classification in
            DispatchQueue.main.async {
                self.result = classification
            }
        }
    }
}

#Preview {
    ContentView()
}
