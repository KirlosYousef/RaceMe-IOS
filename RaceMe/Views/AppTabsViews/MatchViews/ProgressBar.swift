//
//  ProgressBarView.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 02. 25..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import SwiftUI

///The view of the progress bar in the  MatchView.
struct ProgressBar: View {
    
    @State var barColor: Color = Color(.systemGray)
    @State var isShowing = false
    @Binding var progress: CGFloat
    var profPic: String
    var barHeight: CGFloat = 345
    var barWidth: CGFloat = 20
    var isCurrentPlayer : Bool
    
    var body: some View {
        VStack{
            Text(String(Int(self.progress)))
                .font(Font.title)
                .foregroundColor(barColor)
            
            ZStack(alignment: .bottom) {
                
                Rectangle()
                    .foregroundColor(Color(.systemGray4))
                    .opacity(0.3)
                    .frame(width: barWidth, height: barHeight )
                    .cornerRadius(barWidth / 2.0)
                
                ZStack(alignment: .top) {
                    
                    Rectangle()
                        .foregroundColor(barColor)
                        .cornerRadius(barWidth / 2.0)
                        .frame(width: barWidth)
                    
                    KFImageView(picURL: self.profPic, imageWidth: 33, imageHeight: 30, lineWidth: 1)
                    
                }
                .cornerRadius(barWidth / 2.0)
                .frame(height:  self.isShowing ? (barHeight * (self.progress / 100.0)) : 0.0)
                .animation(.linear(duration: 0.6))
                
            }
            .onAppear {
                self.isShowing = true
                if self.isCurrentPlayer{
                    self.barColor = darkBackground
                }
            }
        }
    }
}

#if DEBUG
struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ProgressBar(progress: .constant(25.0), profPic: defaultProfPic, isCurrentPlayer: false)
            ProgressBar(progress: .constant(25.0), profPic: defaultProfPic, isCurrentPlayer: true)
        }
    }
}
#endif
