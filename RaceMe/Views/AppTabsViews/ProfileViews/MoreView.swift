//
//  MoreView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 11. 07..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import SwiftUI
import Combine
import StoreKit

struct MoreView: View {
    
    @EnvironmentObject var login : Login
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var rating: Int = 0
    @State var isShowingMailView = false
    
    var body: some View {
        VStack{
            ScrollView{
                UnitPickerView()
                
                RatingView(rating: self.$rating)
                
                ContactView()
                
                //                SupportMeView()
                
                AboutView()
                
                LogOutButtonView(presentationMode: presentationMode)
                    .environmentObject(login)
            }
            .padding()
        }
        .padding(.top, 20)
        .background(Color(.systemBackground))
        
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            MoreView().environmentObject(Login())
            MoreView().environmentObject(Login())
                .environment(\.colorScheme, .dark)
        }
    }
}


struct UnitPickerView : View{
    @ObservedObject var chosenUnit = ChosenUnit()
    @State private var units = ["Kilometers", "Miles"]
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .systemBlue
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.label], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
    }
    var body : some View{
        VStack{ // Unit Picker
            Text("Distance Units")
                .font(Font.callout)
                .foregroundColor(Color(.label))
            
            Picker(selection: $chosenUnit.selection, label: Text("")) {
                ForEach(units, id: \.self) { unit in
                    Text(unit).tag(unit)
                }
            } .pickerStyle(SegmentedPickerStyle())
            
            Text("Choose your preferred distance unit to be used in the app!")
                .font(Font.caption).foregroundColor(Color(.secondaryLabel))
            
            Divider().padding([.top, .bottom])
        }
    }
}

struct RatingView : View{
    
    @Binding var rating: Int
    
    var label = "Rate The App"
    
    var maximumRating = 5
    
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColor = Color(.secondaryLabel)
    var onColor = darkBackground
    
    func image(for number: Int) -> Image {
        if number > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
    
    var body : some View{
        VStack{
            Text(label)
                .font(Font.callout)
                .foregroundColor(Color(.label))
            HStack {
                ForEach(1..<maximumRating + 1) { number in
                    self.image(for: number)
                        .foregroundColor(number > self.rating ? self.offColor : self.onColor)
                        .onTapGesture {
                            self.rating = number
                            SKStoreReviewController.requestReview()
                    }
                }
            }
            Divider().padding([.top, .bottom])
        }
    }
}

struct SupportMeView : View{
    var body : some View{
        VStack{
            Button(action: {
                
            }) {
                HStack{
                    Text("Support me")
                        .font(Font.callout)
                        .foregroundColor(Color(.label))
                    Spacer()
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            Divider().padding([.top, .bottom])
        }
    }
}

struct AboutView : View{
    var body : some View{
        VStack{
            Button(action: {
                let url = URL.init(string: "https://www.raceme.tech")
                guard let privacyPolicy = url, UIApplication.shared.canOpenURL(privacyPolicy) else { return }
                UIApplication.shared.open(privacyPolicy)
            }) {
                HStack{
                    Text("About")
                        .font(Font.callout)
                        .foregroundColor(Color(.label))
                    Spacer()
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            Divider().padding([.top, .bottom])
        }
    }
}

struct LogOutButtonView : View{
    
    @EnvironmentObject var login : Login
    @Binding var presentationMode: PresentationMode
    @State private var showingLoggingOutAlert = false
    
    var body : some View{
        HStack{ // Log out Button
            Button(action: {
                self.showingLoggingOutAlert.toggle()
            }) {
                Text("Logout")
                    .font(Font.callout)
                    .foregroundColor(Color(.label))
                Spacer()
                
                Image(systemName: "arrowshape.turn.up.left.circle.fill")
                    .font(Font.headline)
                    .foregroundColor(Color(.secondaryLabel))
            }
            .alert(isPresented: $showingLoggingOutAlert) {
                Alert(title: Text("Are you sure you want to Logout?"), primaryButton: .default(Text("I'm sure"), action: {
                    self.login.logout()
                    self.$presentationMode.wrappedValue.dismiss() // Dismiss the modal
                }), secondaryButton: .cancel())
            }
        }
    }
}

final class ChosenUnit: ObservableObject {
    var selection: String = UserDefaults.standard.getDistanceUnit() {
        didSet {
            // If the user changed the unit it will be updated in the UserDefaults.
            UserDefaults.standard.setDistanceUnit(unit: selection)
        }
    }
}
