//
//  SpinRandomizerView.swift
//  Crazy
//
//  Created by D K on 14.12.2024.
//

import SwiftUI

struct SpinRandomizerView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var list: [RandomSpinElement]
    @State private var rotationAngle: Double = 0
    @State private var targetSegmentIndex: Int = 0
    @State private var isSpinning = false
    @State private var isAlerted = false
    @State private var winner = ""
    
    @StateObject private var soundPlayer = SoundPlayer.shared
    
    var body: some View {
        ZStack {
            Image("bgBlur")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    RandomPieChartView(elements: list)
                        .rotationEffect(.degrees(rotationAngle))
                        .frame(width: 300, height: 300)
                    
                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                        .offset(y: -160)
                }              
                
                Button {
                    soundPlayer.playPopSound()
                    spinWheel()
                } label: {
                    Image("spinButton")
                        .resizable()
                        .scaledToFill()
                        .frame(width: size().width - 70, height: 70)
                }
                .shadow(radius: 10)
                .padding(.top, 70)
            }
            
            VStack {
                Text("Random Spin")
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
        .alert("The winner is \(winner)", isPresented: $isAlerted) {
            Button {
                
            } label: {
                Text("Ok")
            }
        }
    }
    
    private func spinWheel() {
        guard !isSpinning else { return }
        rotationAngle = 0
        isSpinning = true
        
        targetSegmentIndex = Int.random(in: 0..<list.count)
        
        let segmentAngle = 360.0 / Double(list.count)
        let targetAngle = segmentAngle * Double(targetSegmentIndex)
        
        let totalRotation = 360.0 * 5 + (360.0 - targetAngle) - 10
        
        withAnimation(Animation.easeOut(duration: 3)) {
            rotationAngle += totalRotation
        }
        
        winner = list[targetSegmentIndex].name
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isSpinning = false
            isAlerted.toggle()
            print("Выпал элемент: \(list[targetSegmentIndex].name)")
        }
    }
}

#Preview {
    SpinRandomizerView(list: .constant([RandomSpinElement(name: "1", color: .green), RandomSpinElement(name: "2", color: .purple), RandomSpinElement(name: "3", color: .blue), RandomSpinElement(name: "4", color: .red), RandomSpinElement(name: "5", color: .systemTeal), RandomSpinElement(name: "6", color: .yellow), RandomSpinElement(name: "7", color: .orange), RandomSpinElement(name: "8", color: .cyan), RandomSpinElement(name: "9", color: .brown), RandomSpinElement(name: "10", color: .magenta)]))
}


struct RandomPieChartView: View {
    let elements: [RandomSpinElement]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(elements.indices, id: \.self) { index in
                    let startAngle = self.startAngle(for: index)
                    let endAngle = self.endAngle(for: index)
                    
                    RandomPieSliceView(startAngle: startAngle, endAngle: endAngle, color: elements[index].color, image: elements[index].image)
                    
                    Text(elements[index].name)
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .position(
                            self.labelPosition(
                                startAngle: startAngle,
                                endAngle: endAngle,
                                in: geometry.size
                            )
                        )
                }
            }
        }
    }
    
    // Вычисление начального угла сектора
    private func startAngle(for index: Int) -> Angle {
        let segmentAngle = 360.0 / Double(elements.count)
        return Angle(degrees: Double(index) * segmentAngle - 90)
    }
    
    // Вычисление конечного угла сектора
    private func endAngle(for index: Int) -> Angle {
        let segmentAngle = 360.0 / Double(elements.count)
        return Angle(degrees: Double(index + 1) * segmentAngle - 90)
    }
    
    // Позиция метки
    private func labelPosition(startAngle: Angle, endAngle: Angle, in size: CGSize) -> CGPoint {
        let middleAngle = (startAngle.radians + endAngle.radians) / 2
        let radius = min(size.width, size.height) / 2 * 0.7
        let x = size.width / 2 + radius * cos(middleAngle)
        let y = size.height / 2 + radius * sin(middleAngle)
        return CGPoint(x: x, y: y)
    }
}

struct RandomPieSliceView: View {
    var startAngle: Angle
    var endAngle: Angle
    var color: UIColor?
    var image: UIImage? // Имя изображения для сегмента
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let center = CGPoint(x: width / 2, y: height / 2)
            let radius = min(width, height) / 2
            
            ZStack {
                
                Path { path in
                    path.move(to: center)
                    path.addArc(center: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: false)
                    path.closeSubpath()
                }
                .fill(Color(uiColor: color ?? .red))
                .shadow(radius: 10)
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipShape(
                            Path { path in
                                path.move(to: center)
                                path.addArc(
                                    center: center,
                                    radius: radius,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: false
                                )
                            }
                        )
                }
                
            }
        }
    }
}
