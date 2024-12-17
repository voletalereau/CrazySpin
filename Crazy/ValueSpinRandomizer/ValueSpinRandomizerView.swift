//
//  ValueSpinRandomizerView.swift
//  Crazy
//
//  Created by D K on 14.12.2024.
//

import SwiftUI

class ValueSpinRandomizerViewModel: ObservableObject {
    func calculateAngles(for elements: [ValueSpinElement], totalWeight: Double) -> [(start: Angle, end: Angle)] {
        var startAngle: Angle = .degrees(0)
        var angles: [(start: Angle, end: Angle)] = []
        
        for element in elements {
            let segment = 1 / (Double(element.quantity) ?? 0) / totalWeight
            let endAngle = startAngle + .degrees(segment * 360)
            angles.append((start: startAngle, end: endAngle))
            startAngle = endAngle
        }
        
        return angles
    }
}

struct ValueSpinRandomizerView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var list: [ValueSpinElement]
    
    @State private var rotationAngle: Double = 0
    @State private var isSpinning = false
    @State private var targetSegmentIndex: Int = 0
    
    @State private var indexToDelete: Int?
    
    @StateObject private var vm = ValueSpinRandomizerViewModel()
    
    @State private var isFirstSpin = true
    
    @State private var elementToRemove: ValueSpinElement?
    @State private var isAlertShown = false
    
    @StateObject private var soundPlayer = SoundPlayer.shared
    
    var body: some View {
        ZStack {
            Image("bgBlur")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                                
                ZStack {
                    // Круговая диаграмма
                    ValuePieChartView(elements: list)
                        .rotationEffect(.degrees(rotationAngle))
                        .frame(width: 300, height: 300)
                    
                    // Указатель
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
                Text("Value Spin")
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
        .alert("The \(elementToRemove?.name ?? "") has dropped out!", isPresented: $isAlertShown) {
            Button {
                isAlertShown = false
            } label: {
                Text("Spin again")
            }
            
            Button {
                if let index = indexToDelete {
                    list.remove(at: index)
                }
                isAlertShown = false
            } label: {
                Text("Remove and spin")
            }
        } message: {
            Text("You can either spin again or remove the element and continue spinning.")
        }

    }
    
    private func spinWheel() {
        guard !isSpinning else { return }
        isSpinning = true
        
        // 1. Логика выбора случайного элемента
        let totalWeight = list.reduce(0) { $0 + 1 / (Double($1.quantity) ?? 0) }
        let randomValue = Double.random(in: 0..<totalWeight)
        var cumulativeSum: Double = 0
        for (index, element) in list.enumerated() {
            cumulativeSum += 1 / (Double(element.quantity) ?? 0)
            if randomValue < cumulativeSum {
                targetSegmentIndex = index
                indexToDelete = index
                // Вычисляем вероятность в процентах
                let chance = (1 / (Double(element.quantity) ?? 0)) / totalWeight * 100
                print("Вылетел: \(element.name), шанс: \(String(format: "%.2f", chance))%")
                elementToRemove = element
                
                break
            }
        }
        
        // 2. Рассчитать углы сегментов
        let segmentAngles = vm.calculateAngles(for: list, totalWeight: totalWeight)
        
        // 3. Угол, на который должен остановиться сегмент
        let targetStartAngle = segmentAngles[targetSegmentIndex].start.degrees
        let targetEndAngle = segmentAngles[targetSegmentIndex].end.degrees
        let targetCenterAngle = (targetStartAngle + targetEndAngle) / 2 + 90
        
        // 4. Текущий угол вращения (нужен для корректной анимации)
        let currentRotation = rotationAngle.truncatingRemainder(dividingBy: 360)
        
        // 5. Вычислить корректный угол для остановки
        let targetRotation = 360 * 5 + (360 - currentRotation - targetCenterAngle)
        
        // 6. Анимация вращения
        withAnimation(Animation.easeOut(duration: 3)) {
            rotationAngle += targetRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isAlertShown.toggle()
            isSpinning = false
        }
    }
    
    private func printAllChances() {
        let totalWeight = list.reduce(0) { $0 + 1 / (Double($1.quantity) ?? 0) }
        print("Шансы выпадения каждого элемента:")
        
        for element in list {
            let chance = (1 / (Double(element.quantity) ?? 0)) / totalWeight * 100
            print("\(element.name): \(String(format: "%.2f", chance))%")
        }
    }
}

#Preview {
    ValueSpinRandomizerView(list: .constant([ValueSpinElement(name: "1", image: nil, color: .purple, quantity: "100"), ValueSpinElement(name: "2", image: nil, color: .green, quantity: "50"), ValueSpinElement(name: "3", image: nil, color: .red, quantity: "300"), ValueSpinElement(name: "4", image: nil, color: .systemTeal, quantity: "100"), ValueSpinElement(name: "5", image: nil, color: .brown, quantity: "120"), ValueSpinElement(name: "6", image: nil, color: .magenta, quantity: "200"), ValueSpinElement(name: "7", image: nil, color: .cyan, quantity: "150"), ValueSpinElement(name: "8", image: nil, color: .yellow, quantity: "90")]))
}



//VALUE PIE CHART

struct ValuePieChartView: View {
    
    @StateObject private var vm = ValueSpinRandomizerViewModel()
    
    let elements: [ValueSpinElement]
    
    var body: some View {
        GeometryReader { geometry in
            let totalWeight = elements.reduce(0) { $0 + 1 / (Double($1.quantity) ?? 0)  }
            let angles = vm.calculateAngles(for: elements, totalWeight: totalWeight)
            
            ZStack {
                ForEach(angles.indices, id: \.self) { index in
                    let angle = angles[index]
                    ValuePieSliceView(
                        startAngle: angle.start,
                        endAngle: angle.end,
                        color: elements[index].color,
                        image: elements[index].image
                    )
                    .overlay(
                        Text(elements[index].name)
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .position(
                                labelPosition(startAngle: angle.start, endAngle: angle.end, in: geometry.size)
                            )
                    )
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func labelPosition(startAngle: Angle, endAngle: Angle, in size: CGSize) -> CGPoint {
        let middleAngle = (startAngle.radians + endAngle.radians) / 2
        let radius = min(size.width, size.height) / 2 * 0.7
        let x = size.width / 2 + radius * cos(middleAngle)
        let y = size.height / 2 + radius * sin(middleAngle)
        return CGPoint(x: x, y: y)
    }
}


struct ValuePieSliceView: View {
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
                // Сегмент с цветным фоном
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
