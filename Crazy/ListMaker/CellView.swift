//
//  CellView.swift
//  Crazy
//
//  Created by D K on 14.12.2024.
//

import SwiftUI

struct CellView: View {
    
    @Binding var element: ValueSpinElement
    
    @State private var isShown = false
    @State private var image: UIImage?
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 140, height: 100)
                .foregroundColor(.black)
                .cornerRadius(12)
                .overlay {
                    TextField("", text: $element.name, prompt: Text("Name").foregroundColor(.white.opacity(0.4)))
                        .foregroundColor(.white)
                        .font(.system(size: 26))
                        .padding(.horizontal, 10)
                        .onChange(of: element.name) { newValue in
                            if newValue.count > 10 {
                                element.name = String(newValue.prefix(10))
                            }
                        }
                }
            
            
            Rectangle()
                .frame(width: 90, height: 100)
                .foregroundColor(.black)
                .cornerRadius(12)
                .overlay {
                    TextField("", text: Binding(
                        get: {
                            element.quantity
                        },
                        set: { newValue in
                            // Оставляем только цифры
                            let filteredValue = newValue.filter { $0.isNumber }
                            element.quantity = filteredValue
                        }
                    ), prompt: Text("Value").foregroundColor(.white.opacity(0.4)))
                    .foregroundColor(.white)
                    .font(.system(size: 26))
                    .padding(.horizontal, 10)
                    .keyboardType(.numberPad) // Числовая клавиатура
                    
                }
            
            
            if let color = element.color, element.image == nil {
                Button {
                    isShown.toggle()
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(width: 90, height: 100)
                            .foregroundColor(Color(uiColor: color))
                            .cornerRadius(12)
                        
                        Image(systemName: "photo")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                    
                }
            }
            
            if let image = element.image {
                
                Button {
                    isShown.toggle()
                } label: {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 100)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .sheet(isPresented: $isShown) {
            BottomSheetView(selectedImage: $image) {
                withAnimation {
                    isShown = false
                    
                    if let image = image {
                        element.image = image
                    }
                }
            } closing: {
                isShown = false
            }
            .presentationDetents([.height(140)])
        }
    }
}

#Preview {
    CellView(element: .constant(ValueSpinElement(name: "", color: UIColor.red, quantity: "")))
}
