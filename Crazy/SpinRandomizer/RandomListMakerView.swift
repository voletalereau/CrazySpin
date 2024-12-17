//
//  RandomListMakerView.swift
//  Crazy
//
//  Created by D K on 14.12.2024.
//

import SwiftUI

extension Array where Element == RandomSpinElement {
    func allFieldsFilled() -> Bool {
        for element in self {
            if element.name.isEmpty {
                return false
            }
        }
        return true
    }
}

struct RandomSpinElement: Hashable {
    var id = UUID()
    var name: String
    var image: UIImage?
    var color: UIColor?
}

struct RandomListMakerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var list: [RandomSpinElement] = [RandomSpinElement(name: "1 Element", color: .blue)]
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
                        RandomCellView(element: element)
                        
                    }
                    HStack {
                        Button {
                            let newElement = RandomSpinElement(name: "", color: getRandomColor())
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
            }
            
        } message: {
            Text("To create a list correctly - add the required number of elements. Enter the name for each element. Optionally, you can add a picture for the element or just leave the color.")
        }
        .fullScreenCover(isPresented: $isPresented) {
            SpinRandomizerView(list: $list)
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
    RandomListMakerView()
}


struct RandomCellView: View {
    
    @Binding var element: RandomSpinElement
    
    @State private var isShown = false
    @State private var image: UIImage?
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 210, height: 100)
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
