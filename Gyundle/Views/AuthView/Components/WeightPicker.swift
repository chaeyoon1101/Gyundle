//
//  WeightPicker.swift
//  Gyundle
//
//  Created by 임채윤 on 2/16/25.
//

import SwiftUI

struct WeightPicker: View {
    @Binding var weight: Double
    
    @State private var intergerSelection: Int = 0
    @State private var decimalSelection: Int = 0
    
    @State private var showPickerView: Bool = false
    var body: some View {
        HStack {
            Text("몸무게")
                .font(.headline)
            
            Spacer()
            
            Text("\(String(format: "%.1f", weight))")
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 30)
        .onTapGesture {
            showPickerView = true
        }
        .sheet(isPresented: $showPickerView) {
            NavigationStack {
                HStack(spacing: -10) {
                    Picker("", selection: $intergerSelection) {
                        ForEach(0...100, id: \.self) { value in
                            Text("\(value)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .onChange(of: intergerSelection) { _, newValue in
                        let decimal = weight.truncatingRemainder(dividingBy: 1.0)
                        
                        weight = Double(newValue) + decimal
                    }
                    
                    Text(".").font(.title)
                    
                    Picker("", selection: $decimalSelection) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .onChange(of: decimalSelection) { _ , newValue in
                        let interger = weight.rounded(.down)
                        
                        weight = interger + Double(newValue) / 10.0
                    }
                    
                    Picker("", selection: .constant("/KG")) {
                        Text("/KG")
                    }
                    .pickerStyle(.wheel)
                }
                .presentationDetents([.height(250)])
                .navigationTitle("몸무게")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("완료") {
                            showPickerView = false
                        }
                        .fontWeight(.bold)
                        .foregroundStyle(ColorConstant.accent)
                    }
                }
            }
        }
    }
}

#Preview {
    WeightPicker(weight: .constant(3.7))
}
