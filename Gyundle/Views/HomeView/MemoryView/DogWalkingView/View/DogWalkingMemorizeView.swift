import SwiftUI

struct DogWalkingMemorizeView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var dogWalkingViewModel: DogWalkingViewModel
//    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    
    @State private var isMapExpanded: Bool = false
    
    var body: some View {
        VStack {
            DogWalkingMapView(isMapExpanded: $isMapExpanded)
                .frame(maxHeight: isMapExpanded ? .infinity : 300)
                .ignoresSafeArea()
            
            Spacer(minLength: 0)
        }
        
    }
}

#Preview {
    DogWalkingMemorizeView()
        .environmentObject(DogWalkingViewModel())
}
