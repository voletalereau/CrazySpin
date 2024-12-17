//
//  ListMakerView.swift
//  Crazy
//
//  Created by D K on 14.12.2024.
//

import SwiftUI

extension Array where Element == ValueSpinElement {
    func allFieldsFilled() -> Bool {
        for element in self {
            if element.name.isEmpty || element.quantity.isEmpty {
                return false
            }
        }
        return true
    }
}

struct ValueSpinElement: Hashable {
    var id = UUID()
    var name: String
    var image: UIImage?
    var color: UIColor?
    var quantity: String
}

struct ListMakerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var list: [ValueSpinElement] = [ValueSpinElement(name: "1 Element", color: .blue, quantity: "100")]
    @State private var isPresented = false
    @State private var isAlerted = false
    
    @State private var isInfoShown = false
    
    var body: some View {
            ZStack {
                Image("bgBlur")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    
                    Text("List Maker")
                        .foregroundStyle(.white)
                        .font(.system(size: 32, weight: .black))
                    
                    ScrollView {
                        ForEach($list, id: \.id) { element in
                            CellView(element: element)
                            
                        }
                        HStack {
                            Button {
                                let newElement = ValueSpinElement(name: "", color: getRandomColor(), quantity: "")
                                list.append(newElement)
                            } label: {
                                ZStack {
                                    Rectangle()
                                        .frame(width: size().width - 70, height: 60)
                                        .foregroundColor(.black)
                                        .cornerRadius(12)
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 32))
                                }
                            }
                        }
                        .padding(.horizontal, 21)
                        .padding(.top)
                    }
                    .scrollIndicators(.hidden)
                    
                    Button {
                        if list.allFieldsFilled() == true {
                            isPresented.toggle()
                        } else {
                            isAlerted.toggle()
                        }
                        
                    } label: {
                        Image("spinButton")
                            .resizable()
                            .scaledToFill()
                            .frame(width: size().width - 70, height: 70)
                    }
                    .shadow(radius: 10)
                    .padding(.bottom, 20)
                }
            }
            .alert("All fields must be filled in", isPresented: $isAlerted) {
                
            }
            .alert("How to create a list?", isPresented: $isInfoShown) {
                Button {
                    
                } label: {
                    Text("Ok")
                }            } message: {
                Text("To create a list correctly - add the required number of elements. Enter the name and value for each element. Optionally, you can add a picture for the element or just leave the color.")
            }
            .fullScreenCover(isPresented: $isPresented) {
                ValueSpinRandomizerView(list: $list)
                    .onDisappear {
                        dismiss()
                    }
            }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isInfoShown.toggle()
                }) {
                    Image(systemName: "info.circle")
                }
            }
        }
    }
    
    func getRandomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

#Preview {
    ListMakerView()
}
