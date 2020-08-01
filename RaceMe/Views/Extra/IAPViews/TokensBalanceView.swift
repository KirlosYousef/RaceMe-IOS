//
//  TokensBalanceView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 22..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

struct TokensBalanceView: View{
    
    @Binding var tokensBalance: String
    @Binding var freeTokensBalance: String
    
    var body: some View{
        
        VStack(alignment: .trailing){
            HStack{
                Text(tokensBalance)
                    .foregroundColor(Color(.systemYellow))
                    .font(.title)
                    .fontWeight(.medium)
                
                Image("Token")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 35, height: 35)
            }
        }
        .padding([.top, .bottom])
        .onAppear {
            getUserData.getTokens { (tokens) in
                let tokensBalance = tokens["tokensBalance"]
                let freeTokensBalance = tokens["freeTokensBalance"]
                
                self.tokensBalance = String(tokensBalance!)
                self.freeTokensBalance = String(freeTokensBalance!)
            }
        }
    }
}

struct TokensBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        TokensBalanceView(tokensBalance: .constant("..."), freeTokensBalance: .constant("..."))
    }
}
