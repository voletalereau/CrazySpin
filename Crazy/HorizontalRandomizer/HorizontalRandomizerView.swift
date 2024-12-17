//
//  HorizontalRandomizerView.swift
//  Crazy
//
//  Created by D K on 14.12.2024.
//

import SwiftUI



struct HorizontalRandomizerView1: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var list: [HorizontalRandomElement]
    
    @State private var offset: CGFloat = 0
    @State private var isSpinning = false
    @State private var targetIndex: Int = 0
    
    @State private var winner = ""
    @State private var isAlerter = false
    
    @StateObject private var soundPlayer = SoundPlayer.shared
    
    var body: some View {
        ZStack {
            Image("bgBlur")
                .resizable()
                .ignoresSafeArea()
            
            
            VStack {
                Spacer()
                ZStack {
                    // Горизонтальная прокрутка элементов
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            // Дублирование массива для имитации бесконечности
                            ForEach(0..<list.count * 10, id: \.self) { index in
                                let element = list[index % list.count]
                                Text(element.name)
                                    .frame(width: 100, height: 100)
                                    .background(Color.random)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                            }
                        }
                        .offset(x: offset)
                        .padding(.leading)
                    }
                    .frame(height: 100)
                    
                    
                    // Стрелка
                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                        .offset(y: -65)
                }
                
                Spacer()
                
                Button {
                    soundPlayer.playPopSound()
                    spin()
                } label: {
                    Image("spinButton")
                        .resizable()
                        .scaledToFill()
                        .frame(width: size().width - 70, height: 70)
                }
                .shadow(radius: 10)
                .padding(.bottom, 70)
            }
            
            VStack {
                Text("Horizontal Spin")
                    .foregroundColor(.white)
                    .font(.system(size: 32, weight: .black))
                
                Spacer()
            }
            
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                    .padding(.top, 13)
                    .padding(.leading)
                    Spacer()
                }
                Spacer()
            }
        }
        .alert("The winner is \(winner)", isPresented: $isAlerter) {
            Button {
                
            } label: {
                Text("Ok")
            }
        }
    }
    
    
    private func spin() {
        
        guard !isSpinning else { return }
        offset = 0
        isSpinning = true
        
        // Выбор случайного индекса
        targetIndex = Int.random(in: 0..<list.count)
        
        // Расчет конечного смещения
        let itemWidth: CGFloat = 110 // ширина элемента + отступы
        let targetOffset = -(CGFloat(list.count * 5 + targetIndex) * itemWidth) + 150
        
        // Анимация прокрутки
        withAnimation(Animation.easeOut(duration: 3)) {
            offset = targetOffset
        }
        
        // Завершение и вывод победителя
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isSpinning = false
            winner = list[targetIndex].name
            isAlerter.toggle()
            print("Победитель: \(winner)")
        }
    }
}

#Preview {
    HorizontalRandomizerView1(list: .constant([HorizontalRandomElement(name: "1", color: .red), HorizontalRandomElement(name: "2", color: .blue), HorizontalRandomElement(name: "3", color: .purple), HorizontalRandomElement(name: "4", color: .green)]))
}

extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}
