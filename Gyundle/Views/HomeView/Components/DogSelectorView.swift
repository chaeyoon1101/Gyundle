//
//  DogSelectorView.swift
//  Gyundle
//
//  Created by 임채윤 on 2/18/25.
//

import SwiftUI

struct DogSelectorView: View {
    @StateObject private var userManager = UserManager.shared
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(userManager.user?.dogs ?? [], id: \.id) { dog in
                    DogProfile(dog)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func DogProfile(_ dog: Dog) -> some View {
        VStack(spacing: 8) {
            CachedAsyncImage(url: URL(string: dog.photoURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(.circle)
                        .contentShape(.circle)
                case .empty:
                    Image(systemName: "dog.fill")
                        .background(ColorConstant.bgContent, in: .circle)
                case .failure(_):
                    Image(systemName: "dog.fill")
                        .background(ColorConstant.bgContent, in: .circle)
                @unknown default:
                    Image(systemName: "dog.fill")
                        .background(ColorConstant.bgContent, in: .circle)
                }
            }
            .frame(width: 52, height: 52)
            .overlay {
                if dog == userManager.selectedDog {
                    Circle()
                        .stroke(
                           LinearGradient(
                                gradient: Gradient(colors: [
                                    ColorConstant.accent,
                                    ColorConstant.fgSecondary,
                                    ColorConstant.accent,
                                    ColorConstant.fgSecondary
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                           ),
                           lineWidth: 4
                       )
                        .frame(width: 60, height: 60)
                }
            }
            
            Text(dog.name)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(width: 60)
        .onTapGesture {
            userManager.selectedDog = dog
        }
    }
}

#Preview {
    HomeView(showMemorizeView: .constant(false))
        .environmentObject(DogWalkingMemoryViewModel())
        .environmentObject(DailyMemoryViewModel())
        .environmentObject(CalendarViewModel())
}
