//
//  MainView.swift
//  Crazy
//
//  Created by D K on 14.12.2024.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("bgBlur")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    Image("logo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 400, height: 280)
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            NavigationLink {
                                ListMakerView()
                            } label: {
                                Image("valueButton")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size().width - 20, height: 70)
                                    .shadow(radius: 10)
                            }
                            
                            NavigationLink {
                                RandomListMakerView()
                            } label: {
                                Image("randomButton")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size().width - 20, height: 70)
                                    .shadow(radius: 10)
                            }
                            
                            NavigationLink {
                                HorizontalMakerView()
                            } label: {
                                Image("horizontalButton")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size().width - 20, height: 70)
                                    .shadow(radius: 10)
                            }
                            
                            
                            NavigationLink {
                                InfoView()
                            } label: {
                                Image("infoButton")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size().width - 20, height: 70)
                                    .shadow(radius: 10)
                            }
                          
                            NavigationLink {
                                SettingsView()
                            } label: {
                                Image("settingsButton")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size().width - 20, height: 70)
                                    .shadow(radius: 10)
                            }
                            .padding(.bottom, 150)
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .tint(.white)
    }
}

#Preview {
    MainView()
}
