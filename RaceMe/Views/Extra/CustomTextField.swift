//
//  CustomTextField.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 11..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct CustomTextField: View {
    
    @State var placeholder: String
    @State var isSecured: Bool = false
    @Binding var textHolder: String
    @State private var showClearButton: Bool = false
    
    var body: some View{
        VStack{
            if isSecured{
                
                SecureField(placeholder, text: self.$textHolder).modifier(TextFieldModifier(text: self.$textHolder, visible: .constant(false)))
                
            } else {
                
                TextField(self.placeholder, text: self.$textHolder, onEditingChanged: { isEditing in
                    self.showClearButton = isEditing
                }, onCommit: {
                    self.showClearButton = false
                })
                    .modifier(TextFieldModifier(text: self.$textHolder, visible: self.$showClearButton))
                    .resignKeyboardOnDragGesture()
            }
        }
    }
}


struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            CustomTextField(placeholder: "Test", textHolder: .constant(""))
            CustomTextField(placeholder: "Test", textHolder: .constant(""))
                .environment(\.colorScheme, .dark)
        }
    }
}
