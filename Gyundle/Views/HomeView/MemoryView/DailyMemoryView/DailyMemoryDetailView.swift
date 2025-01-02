//
//  DailyMemoryDetailView.swift
//  Gyundle
//
//  Created by 임채윤 on 1/2/25.
//

import SwiftUI

struct DailyMemoryDetailView: View {
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    @Binding var isPresented: Bool
    
    var body: some View {
        Text("Hello, World!")
        
        
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(DetailImageViewModel())
}
