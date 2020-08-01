//
//  ContactView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 16..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI
import UIKit
import MessageUI

struct ContactView : View{
    
    @State private var didPressMail: Bool = false
    @State private var canSendMail: Bool = true
    @State private var value: CGFloat = 0
    
    var body : some View{
        VStack{
            Button(action: {
                self.didPressMail = true
            }) {
                HStack{
                    Text("Contact us")
                        .font(Font.callout)
                        .foregroundColor(Color(.label))
                    Spacer()
                    Image(systemName: "envelope.fill")
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            Divider().padding([.top, .bottom])
        }.sheet(isPresented: self.$didPressMail) {
            if self.canSendMail{
                ContactViewRepresentable(canSendMail: self.$canSendMail)
            } else {
                VStack{
                    Text("You don't have mail app setup.")
                    
                    Text("Plese use the following email to reach us:")
                    
                    Text("support@raceme.tech")
                }
            }
        }
    }
}


struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        ContactView()
    }
}


struct ContactViewRepresentable: UIViewControllerRepresentable { // Representable SwiftUI view for Contact View.
    
    @State private var mailTo: String? = "support@raceme.tech"
    @State var mailSubject: String? = "RaceMe-Support"
    @State var mailBody: String? = ""
    @Binding var canSendMail: Bool
    
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ContactViewRepresentable>) -> UIViewController {
        var vc = UIViewController()
        if MFMailComposeViewController.canSendMail(){
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = context.coordinator
            mailComposeVC.setToRecipients([self.mailTo!])
            mailComposeVC.setSubject(self.mailSubject!)
            mailComposeVC.setMessageBody(self.mailBody!, isHTML: false)
            self.canSendMail = true
            
            vc = mailComposeVC
        } else{
            self.canSendMail = false // Can't send email
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ContactViewRepresentable> ) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var mailController: ContactViewRepresentable
        
        init(_ mailController: ContactViewRepresentable){
            self.mailController = mailController
        }
        
        //MARK: - MFMail compose method
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
        }
        
    }
}

