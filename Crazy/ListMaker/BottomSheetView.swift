//
//  BottomSheetView.swift
//  Crazy
//
//  Created by D K on 14.12.2024.
//

import SwiftUI

struct BottomSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var showCamera = false
    @State private var showPicker = false
    
    @Binding var selectedImage: UIImage?
    
    var completion: () -> ()
    var closing: () -> ()
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.black.opacity(0.01))
                .onTapGesture {
                    dismiss()
                    closing()
                }
                .overlay {
                    VStack {
                        Spacer()
                        ZStack {
                            Rectangle()
                                .foregroundColor(.black)
                                .frame(height: 200)
                                .cornerRadius(12)
                                .shadow(color: .white.opacity(0.5), radius: 1)
                                .overlay {
                                    VStack {
                                        Capsule()
                                            .frame(width: 60, height: 10)
                                            .foregroundColor(.white.opacity(0.1))
                                            .padding(.top, 10)
                                        Spacer()
                                    }
                                    
                                }
                            
                            HStack {
                                Button {
                                    showCamera.toggle()
                                } label: {
                                    Rectangle()
                                        .foregroundColor(.gray.opacity(0.5))
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(12)
                                        .overlay {
                                            VStack {
                                                Image(systemName: "camera")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 30, height: 30)
                                                    .padding(.bottom, 10)
                                                Text("Camera")
                                            }
                                            
                                        }
                                }
                                
                                Button {
                                    showPicker.toggle()
                                } label: {
                                    Rectangle()
                                        .foregroundColor(.gray.opacity(0.5))
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(12)
                                        .overlay {
                                            VStack {
                                                Image(systemName: "photo.on.rectangle.angled")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 30, height: 30)
                                                    .padding(.bottom, 10)
                                                Text("Library")
                                            }
                                        }
                                }
                            }
                            .tint(.white)
                        }
                    }
                }
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
                .onDisappear {
                    if let _ = selectedImage {
                        completion()
                    }
                }
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}



struct ImagePicker: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @Binding var selectedImage: UIImage?
    
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
