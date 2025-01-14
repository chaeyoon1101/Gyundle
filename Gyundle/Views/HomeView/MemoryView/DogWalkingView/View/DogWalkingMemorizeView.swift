import SwiftUI

struct DogWalkingMemorizeView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var dogWalkingViewModel: DogWalkingViewModel
//    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    
    @State private var isMapExpanded: Bool = false
    
    var body: some View {
        ZStack {
            Self.background(color: ColorConstant.bgPrimary)
            
            VStack {
                DogWalkingMapView(isMapExpanded: $isMapExpanded)
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
        }
    }
    
    @ViewBuilder
    private func DogWalkingDataView() -> some View {
        VStack {
            VStack {
                Text("34:01")
                    .font(.system(size: 56))
                    .bold()
                
                Text("산책 시간")
                    .font(.subheadline)
                    .foregroundStyle(ColorConstant.fgSecondary)
            }
            .padding(.bottom, 30)
            
            HStack {
                DogWalkingDataContent(data: "1.12km", subtitle: "산책 거리")
                
                DogWalkingDataContent(data: "3.8km/h", subtitle: "산책 속도")
                
                DogWalkingDataContent(data: "7.5kcal", subtitle: "칼로릴 소모량")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    @ViewBuilder
    private func DogWalkingDataContent(data: String, subtitle: String) -> some View {
        VStack {
            Text(data)
                .font(.title2)
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

#Preview {
    DogWalkingMemorizeView()
        .environmentObject(DogWalkingViewModel())
}

