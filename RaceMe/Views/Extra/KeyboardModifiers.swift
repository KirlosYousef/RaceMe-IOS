//
//  KeyboardGuardian.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 11. 17..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import Foundation
import SwiftUI

/// This is to mange the textfield position and move it up whenever the keyboard appears.
struct TextFieldModifier: ViewModifier {
    @Binding var text: String
    @Binding var visible: Bool
    func body(content: Content) -> some View {
        ZStack{
            content
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5.0)
                .padding([.trailing,.leading], 20)
            
            Button(action: {
                self.text = ""
            }) {
                Image(systemName: "multiply.circle.fill")
                    .foregroundColor(.secondary)
            }.padding(.leading, 300)
                .opacity(visible ? 1 : 0)
        }
        
    }
}

struct OnTextFieldAppearedModifier: ViewModifier {
    @Binding var value: CGFloat
    var heightController: CGFloat
    func body(content: Content) -> some View {
        ZStack{
            content
                // Keyboard settings to move it the textfield up whenever it's opened.
                .resignKeyboardOnDragGesture()
                .offset(y: -self.value)
                .animation(.spring())
                .onAppear {
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { (noti) in
                        let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                        let height = value.height / self.heightController
                        
                        self.value = height
                    }
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                        
                        self.value = 0
                    }
            }
        }
    }
}

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}
