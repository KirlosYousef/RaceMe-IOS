//
//  NewUserView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 12..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI
import struct Kingfisher.KFImage

struct ProfileDataInsertView: View {
    
    @State var profileName: String = ""
    @State private var value: CGFloat = 0
    @State private var invalidName: Bool = false
    @State private var showAction: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var loading: Bool = false
    @State private var uiImage: UIImage? = nil
    @EnvironmentObject var login : Login
    
    var body: some View {
        GeometryReader{ geometry in
            VStack(alignment: .leading){
                
                Text("Welcome To RaceMe!")
                    .font(.largeTitle)
                    .foregroundColor(.darkColor)
                    .padding()
                    .offset(y: -self.value)
                
                Text("We just need a few information to complete your profile.")
                    .font(.title)
                    .foregroundColor(Color(.secondaryLabel))
                    .padding()
                    .offset(y: -self.value)
                
                VStack(alignment: .center){
                    
                    ProfilePictureEdit(uiImage: self.$uiImage, showAction: self.$showAction, showImagePicker: self.$showImagePicker, imageWidthAndHeight: geometry.size.width / 4)
                        .padding()
                        .onTapGesture {
                            if self.uiImage != nil{
                                self.showAction = true
                            } else{
                                self.showImagePicker = true
                            }
                    }
                    
                    CustomTextField(placeholder: "Profile Name", textHolder: self.$profileName)
                    
                    UnitPickerView()
                        .padding()
                    
                    if self.value == 0 {
                        Spacer()
                    }
                    
                    if self.invalidName{
                        Text("Please enter a profile name.")
                            .foregroundColor(Color(.systemRed))
                    }
                    
                    if !self.login.newUserDataFeedback.isEmpty{
                        Text(self.login.newUserDataFeedback)
                            .foregroundColor(Color(.systemRed))
                            .onAppear {
                                self.loading = false
                        }
                    }
                    
                    Button(action: {
                        if self.profileName.isEmpty{
                            self.invalidName = true
                        } else {
                            self.login.newUserDataFeedback = ""
                            self.loading = true
                            self.invalidName = false
                            self.login.updateUserName(profileName: self.profileName)
                        }
                    }) {
                        if self.loading{
                            ActivityIndicator()
                        } else {
                            Text("Done")
                                .modifier(ButtonModifier())
                        }
                    }.disabled(self.loading)
                        .padding()
                    
                    Spacer()
                    
                }
            }
        }.onDisappear {
            self.loading = false
        }
    }
}

struct NewUserView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ProfileDataInsertView()
                .environmentObject(Login())
            
            ProfileDataInsertView()
                .environmentObject(Login())
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
        }
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var isShown: Bool
    @Binding var uiImage: UIImage?
    @Binding var imageURL: String?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        @Binding var isShown: Bool
        @Binding var uiImage: UIImage?
        @Binding var imageURL: String?
        
        init(isShown: Binding<Bool>, uiImage: Binding<UIImage?>, imageURL: Binding<String?>) {
            _isShown = isShown
            _uiImage = uiImage
            _imageURL = imageURL
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            
            if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
                let imgName = imgUrl.lastPathComponent
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                let localPath = documentDirectory?.appending(imgName)
                
                uiImage = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
                let data = uiImage!.jpegData(compressionQuality: 0)! as NSData
                data.write(toFile: localPath!, atomically: true)
                
                imageURL = localPath
                
                isShown = false
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isShown = false
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShown: $isShown, uiImage: $uiImage, imageURL: $imageURL)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
}


struct ProfilePictureEdit: View {
    
    @Binding var uiImage: UIImage?
    @Binding var showAction: Bool
    @Binding var showImagePicker: Bool
    @State var imageWidthAndHeight: CGFloat
    @State var imageURL: String? = nil
    @EnvironmentObject var login : Login
    
    var sheet: ActionSheet {
        ActionSheet(
            title: Text("Profile Picture"),
            message: Text("Please choose whether you want to change your profile picture or remove it."),
            buttons: [
                .default(Text("Change"), action: {
                    self.showAction = false
                    self.showImagePicker = true
                }),
                .cancel(Text("Close"), action: {
                    self.showAction = false
                }),
                .destructive(Text("Remove"), action: {
                    self.showAction = false
                    self.uiImage = nil
                    self.imageURL = defaultProfPic
                    self.login.newUserPic(pictureLocalPath: defaultProfPic)
                })
        ])
        
    }
    
    var body: some View{
        VStack{
            
            if (self.uiImage == nil) {
                KFImageView(picURL: getUserData.currentUserData.image, imageWidth: imageWidthAndHeight, imageHeight: imageWidthAndHeight)
            } else {
                Image(uiImage: self.uiImage!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageWidthAndHeight, height: imageWidthAndHeight)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Circle())
            }
        }
        .sheet(isPresented: self.$showImagePicker, onDismiss: {
            self.showImagePicker = false
            if self.imageURL != nil{
                self.login.newUserPic(pictureLocalPath: self.imageURL!)
                UserDefaults.standard.setUserPhoto(value: self.imageURL!)
            }
        }, content: {
            ImagePicker(isShown: self.$showImagePicker, uiImage: self.$uiImage, imageURL: self.$imageURL)
        })
            .actionSheet(isPresented: self.$showAction) {
                self.sheet
        }
    }
}
