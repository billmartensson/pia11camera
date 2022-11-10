//
//  ContentView.swift
//  Pia11camera
//
//  Created by Bill Martensson on 2022-11-10.
//

import SwiftUI
import UIKit
import FirebaseStorage
import AVFoundation

struct ContentView: View {
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var displayImage: UIImage?
    @State private var isImagePickerDisplay = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                if displayImage != nil {
                    Image(uiImage: displayImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .frame(width: 300, height: 300)
                } else {
                    Image(systemName: "snow")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .frame(width: 300, height: 300)
                }
                
                Button("Camera") {
                    self.sourceType = .camera
                    self.isImagePickerDisplay.toggle()
                }.padding()
                
                Button("photo") {
                    self.sourceType = .photoLibrary
                    self.isImagePickerDisplay.toggle()
                }.padding()
            }
            .navigationBarTitle("Demo")
            .sheet(isPresented: self.$isImagePickerDisplay) {
                ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
            }
            .onChange(of: selectedImage) { newValue in
                print("BILD VALD!!!")
                
                uploadImage()
            }
            .onAppear() {
                downloadImage()
            }
        }
    }
    
    func uploadImage() {
        print(selectedImage!.size)
        
        let smallImage = resizeImage(fullimage: selectedImage!)
        displayImage = smallImage
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let saveplace = storageRef.child("images").child("bilden.jpg")
        
        let imagedata = smallImage.jpegData(compressionQuality: 0.8)
        
        saveplace.putData(imagedata!, metadata: nil) { (metadata, error) in
            
            if(error != nil) {
                // FEL VID UPPLADDNING
                print("FEL VID UPPLADDNING")
            } else {
                // UPPLADDNING OK
                print("OK UPPLADDNING")
            }
            
        }
    }
    
    func downloadImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let saveplace = storageRef.child("images").child("bilden.jpg")
        
        saveplace.getData(maxSize: 5*1024*1024) { data, error in
            if(error != nil)
            {
                print("FEL VID HÄMTNING")
            } else {
                print("OK HÄMTNING")
                
                let downloadedimage = UIImage(data: data!)
                displayImage = downloadedimage
            }
        }
    }
    
    
    func resizeImage(fullimage : UIImage) -> UIImage {
        
        let maxSize = CGSize(width: 100, height: 100)

        let availableRect = AVFoundation.AVMakeRect(aspectRatio: fullimage.size, insideRect: .init(origin: .zero, size: maxSize))
        let targetSize = availableRect.size

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        let resized = renderer.image { (context) in
            fullimage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return resized
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct ImagePickerView: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    var sourceType: UIImagePickerController.SourceType
        
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator // confirming the delegate
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }

    // Connecting the Coordinator class with this struct
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePickerView
    
    init(picker: ImagePickerView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImage = selectedImage
        self.picker.isPresented.wrappedValue.dismiss()
    }
    
}
