import SwiftUI

struct DogWalkingMemorizeView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var dogWalkingViewModel: DogWalkingMemoryViewModel
    
    @StateObject private var dogWalkingMemorizeViewModel = DogWalkingMemorizeViewModel()
    @StateObject private var locationDataManager = LocationDataManager()
    
    @State private var isMapExpanded: Bool = false
    
    var body: some View {
        ZStack {
            Self.background(color: ColorConstant.bgPrimary)
            
            VStack {
                DogWalkingMapView(isMapExpanded: $isMapExpanded)
                    .environmentObject(locationDataManager)
                    .ignoresSafeArea()
                    .frame(maxHeight: .infinity)
                
                if !isMapExpanded {
                    VStack(spacing: 15) {
                        DogWalkingDataView()
                        
                        DogWalkingStopButton()
                        
                        DogWalkingFuctionButtons()
                            .padding(.top, 30)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ColorConstant.bgSecondary)
                            .ignoresSafeArea()
                    )
                    .padding(.horizontal, 4)
                }
            }
            .onReceive(dogWalkingMemorizeViewModel.timerPublisher) { _ in
                dogWalkingMemorizeViewModel.timeSeconds += 1
                
                dogWalkingMemorizeViewModel.updateDogWalkingData(
                    totalDistance: locationDataManager.totalDistance
                )
            }
        }
    }
    
    @ViewBuilder
    private func DogWalkingDataView() -> some View {
        VStack {
            VStack {
                Text(dogWalkingMemorizeViewModel.dogWalkingTime)
                    .font(.system(size: 56))
                    .bold()
                
                Text("산책 시간")
                    .font(.subheadline)
                    .foregroundStyle(ColorConstant.fgSecondary)
            }
            .padding(.bottom, 30)
            
            HStack {
                DogWalkingDataContent(data: dogWalkingMemorizeViewModel.dogWalkingDistance, subtitle: "산책 거리")
                
                DogWalkingDataContent(data: dogWalkingMemorizeViewModel.dogWalkingSpeed, subtitle: "산책 속도")
                
                DogWalkingDataContent(data: dogWalkingMemorizeViewModel.dogWalkingCalories, subtitle: "칼로리 소모량")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    @ViewBuilder
    private func DogWalkingDataContent(data: String, subtitle: String) -> some View {
        VStack {
            Text(data)
                .font(.title3)
                .bold()
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(ColorConstant.fgSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func DogWalkingStopButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "stop.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(ColorConstant.bgPrimary)
                .frame(width: 32, height: 32)
                .frame(width: 96, height: 96)
                .background(
                    Circle().fill(ColorConstant.fgPrimary)
                )
        }
    }
    
    @ViewBuilder
    private func DogWalkingFuctionButtons() -> some View {
        HStack(spacing: 45) {
            Button {
                
            } label: {
                Image("DogPee")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.yellow)
            }
            .buttonStyle(DogWalkingFunctionsButtonStyle())
            
            Button {
                
            } label: {
                Image("DogPoop")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.brown)
            }
            .buttonStyle(DogWalkingFunctionsButtonStyle())
            
            Button {
                
            } label: {
                Image(systemName: "camera.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(ColorConstant.fgPrimary)
            }
            .buttonStyle(DogWalkingFunctionsButtonStyle())
        }
    }
}

fileprivate struct DogWalkingFunctionsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 20, height: 20)
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(ColorConstant.bgContent)
                    .strokeBorder(ColorConstant.fgPrimary, lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

//#Preview {
//    DogWalkingMemorizeView()
//        .environmentObject(DogWalkingMemoryViewModel())
//}

