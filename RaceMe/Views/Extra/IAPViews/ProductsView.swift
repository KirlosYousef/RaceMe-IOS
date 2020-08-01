//
//  ProductsView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 20..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI
import StoreKit

struct ProductsView: View {
    
    @Binding var didChoose: Bool
    @Binding var tokensBalance: String
    @State private var errorMessage: String = ""
    @State private var errorPurchsing: String = ""
    @State private var isLoading: Bool = true
    @State private var iapProducts = IAPProducts()
    @State private var purchasing = Purchasing()
    @State private var showingRestoreAlert: Bool = false
    
    private func showIAPRelatedError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
    
    private func fetchProducts(){
        IAPManager.shared.getProducts { (result) in
            switch result {
            case .success(let products): self.iapProducts.products = products
            case .failure(let error): self.showIAPRelatedError(error)
            }
            self.isLoading = false
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                
                ProductsTopView(didChoose: self.$didChoose, tokensBalance: self.$tokensBalance)
                
                VStack{
                    if self.isLoading{
                        Spacer()
                        ActivityIndicator()
                        Spacer()
                    } else {
                        
                        ScrollView{
                            ForEach(self.iapProducts.products.reversed(), id: \.self){ product in
                                VStack{
                                    if !(product.productIdentifier.contains("AdFree") && UserDefaults.standard.isAdFree()){
                                        ProductButtonView(product: product, purchasing: self.$purchasing, errorMessage: self.$errorMessage, tokensBalance: self.$tokensBalance)
                                            .padding([.leading, .trailing])
                                            .padding(.bottom, 10)
                                    }
                                }
                            }
                        }.frame(width: screenWidth)
                        
                        ProductsBottomView(errorMessage: self.$errorMessage, purchasing: self.$purchasing, showingRestoreAlert: self.$showingRestoreAlert)
                    }
                    
                }
            }
            .frame(width: screenWidth)
            .onAppear {
                self.isLoading = true
                self.fetchProducts()
            }
            .alert(isPresented: self.$showingRestoreAlert) { () -> Alert in
                Alert(title: Text("Restoring purchase"), message: Text("If you have a purchase it will be restored."), dismissButton: .default(Text("Ok")))
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

private struct ProductsTopView: View {
    
    @Binding var didChoose: Bool
    @Binding var tokensBalance: String
    private let gradient = Gradient(colors: [Color.darkColor, Color.lightColor])
    
    var body: some View{
        VStack{
            VStack{
                Text("Get more tokens!")
                    .font(.title)
                Text("You can choose a bundle to buy,")
                Text("in order to get more tokens into your account!")
            }
            .multilineTextAlignment(.center)
            .font(.subheadline)
            HStack{
                TokensBalanceView(tokensBalance: self.$tokensBalance, freeTokensBalance: .constant("..."))
                    .padding(.leading)
                Spacer()
                CancelButton(didPress: self.$didChoose)
            }
        }
        .padding([.leading, .trailing])
        .padding(.top, 50)
        .frame(width: screenWidth)
        .foregroundColor(Color(.white))
        .background(RoundedCorners(fill: LinearGradient(gradient: self.gradient, startPoint: .topTrailing, endPoint: .bottomLeading), tl: 0, tr: 0, bl: 50, br: 50))
    }
}

private struct ProductsBottomView: View {
    
    @Binding var errorMessage: String
    @Binding var purchasing: Purchasing
    @Binding var showingRestoreAlert: Bool
    
    var body: some View{
        VStack{
            Text(self.errorMessage)
                .frame(width: screenWidth)
            
            if self.purchasing.errorMsg != nil{
                Text(self.purchasing.errorMsg!)
            }
            
            // TO DO 
//            if !UserDefaults.standard.isAdFree(){
//                Button(action: {
//                    self.purchasing.restorePurchases()
//                    self.showingRestoreAlert = true
//                }) {
//                    Text("Restore purchase")
//                        .font(.caption)
//                        .foregroundColor(darkBackground)
//                        .fontWeight(.medium)
//                        .padding(.bottom)
//                }
//            }
        }
    }
}

private struct ProductButtonView: View{
    
    @State private var gradient: Gradient = Gradient(colors: [Color(#colorLiteral(red: 0.8274509804, green: 0, blue: 0.5529411765, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.1725490196, blue: 0.6117647059, alpha: 1))])
    @State private var promo: String = ""
    @State var product: SKProduct
    @Binding var purchasing: Purchasing
    @Binding var errorMessage: String
    @Binding var tokensBalance: String
    
    var body: some View{
        VStack{
            Button(action: {
                self.purchasing.purchase(product: self.product, handler: { response in
                    if response == -1 {
                        self.errorMessage = "In-App Purchases are not allowed in this device."
                    } else {
                        if response != 0 {
                            self.tokensBalance = String(response)
                        }
                    }
                })
            }) {
                HStack(alignment: .center){
                    Image(product.localizedTitle)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: screenWidth / 7)
                    
                    Spacer()
                    
                    VStack{
                        Text(product.localizedTitle)
                            .font(.callout)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                        
                        
                        Text(product.localizedDescription)
                            .font(.subheadline)
                            .fontWeight(.light)
                            .multilineTextAlignment(.center)
                    }.foregroundColor(Color(.label))
                    
                    Spacer()
                    
                    VStack{
                        Text(IAPManager.shared.getPriceFormatted(for: product) ?? "Unavailable")
                            .font(.footnote)
                            .fontWeight(.light)
                            .padding(5)
                            .foregroundColor(Color(.label))
                        
                        Text(promo)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(5)
                            .foregroundColor(Color(.white))
                            .background(
                                LinearGradient(gradient: gradient, startPoint: .topTrailing, endPoint: .bottomLeading)
                                    .cornerRadius(10))
                    }
                    .frame(width: screenWidth / 3.5)
                }
            }
            
        }
        .onAppear {
            switch(self.product.productIdentifier){
                // TO FILL
            case "Small": // SmallBundle ID
                self.gradient = Gradient(colors: [Color(#colorLiteral(red: 0.3294117647, green: 0.431372549, blue: 0.4784313725, alpha: 1)), Color(#colorLiteral(red: 0.3764705882, green: 0.4901960784, blue: 0.5450980392, alpha: 1))])
                self.promo = "Cheapest"
                break
            case "Medium": // MediumBundle ID
                self.gradient = Gradient(colors: [Color(#colorLiteral(red: 0.6980392157, green: 0.2352941176, blue: 0.03137254902, alpha: 1)), Color(#colorLiteral(red: 0.8274509804, green: 0.3529411765, blue: 0.1176470588, alpha: 1))])
                self.promo = "Most popular"
                break
            case "Big": // BigBundle ID
                self.gradient = Gradient(colors: [Color(#colorLiteral(red: 0.06666666667, green: 0.3450980392, blue: 0.7490196078, alpha: 1)), Color(#colorLiteral(red: 0.1294117647, green: 0.3882352941, blue: 0.8078431373, alpha: 1))])
                self.promo = "Best value"
                break
            case "AdFree": // AdFree ID
                self.promo = "Lifetime"
                break
            default:
                break
            }
        }
    }
}

private struct CancelButton: View {
    
    @Binding var didPress: Bool
    
    var body: some View{
        Button(action: {
            self.didPress = false
        }) {
            Image(systemName: "xmark")
                .font(.title)
        }.padding()
    }
}

struct ProductsView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ProductsView(didChoose: .constant(true), tokensBalance: .constant("1"))
            
            ProductsView(didChoose: .constant(true), tokensBalance: .constant("1"))
                .background(Color(.black))
                .environment(\.colorScheme, .dark)
        }
    }
}
