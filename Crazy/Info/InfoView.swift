//
//  InfoView.swift
//  Crazy
//
//  Created by D K on 15.12.2024.
//

import SwiftUI

struct InfoView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Image("bgBlur")
                .resizable()
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    Text("Our app features a unique random selection system using spinning mechanics. There are three spin types available:")
                        
                    
                    Text("1. Value Spin:")
                        .font(.system(size: 32, weight: .black))
                        .padding(.top)
                    
                    Image("valueSpin")
                        .resizable()
                        .frame(width: 150, height: 150)
                    
                    Text(
                         """
                          In this mode, you create a list of elements and assign a weight (value) to each. The spin is drawn inversely proportional to the value—elements with higher weights will have smaller sectors on the spinner, reducing their chances of being selected. This is perfect for scenarios like streamers organizing game suggestions, where donations influence the probability of winning (higher donations = lower sector size). This is an elimination-style spin, meaning you spin repeatedly until only one element remains.
                         """)
                    
                    Text("2. Random Spin:")
                        .font(.system(size: 32, weight: .black))
                        .padding(.top)
                    
                    Image("randomSpin")
                        .resizable()
                        .frame(width: 150, height: 150)
                    
                    Text(
                         """
                          Create a list of elements where each has an equal chance of being selected. No weights, no elimination—just spin and get a winner!
                         """)
                    
                    Text("2. Horizontal Spin:")
                        .font(.system(size: 32, weight: .black))
                        .padding(.top)
                    
                    Image("horizontalSpin")
                        .resizable()
                        .frame(width: 150, height: 150)
                    
                    Text(
                         """
                          Similar to the Random Spin, but instead of a circular spinner, the elements are displayed as horizontal rectangles that scroll horizontally to determine the winner.
                         """)
                    .padding(.bottom, 150)
                }
                        .foregroundColor(.white)
                .padding()
                .background {
                    Rectangle()
                        .foregroundColor(.black.opacity(0.6))
                        .cornerRadius(12)
                        
                }
            }
            .scrollIndicators(.hidden)
            .padding(.top, 100)
           
            
            
            VStack {
                Text("App Mechanics Description")
                    .foregroundColor(.white)
                    .font(.system(size: 32, weight: .black))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
        }
    }
}

#Preview {
    InfoView()
}
