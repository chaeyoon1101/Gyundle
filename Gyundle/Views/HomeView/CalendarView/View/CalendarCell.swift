//
//  CalendarCell.swift
//  Gyundle
//
//  Created by 임채윤 on 2/9/25.
//

import SwiftUI

struct CalendarCell: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    @EnvironmentObject private var dailyMemoryViewModel: DailyMemoryViewModel
    @EnvironmentObject private var dogWalkingMemoryViewModel: DogWalkingMemoryViewModel
    
    let day: Int
    
    var body: some View {
        CachedAsyncImage(url: getRepresentativeImageURL(), scale: 0.5) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(.rect(cornerRadius: 12))
                    .opacity(0.7)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.clear)
                            .stroke(
                                calendarViewModel.isSelectedDate(day: day) ?
                                ColorConstant.accent : calendarViewModel.isToday(day: day) ?
                                ColorConstant.fgPrimary : Color.clear,
                                
                                lineWidth: 4
                            )
                        
                        Text(day, format: .number)
                            .fontWeight(.bold)
                    }
                    .onTapGesture {
                        calendarViewModel.selectDate(day: day)
                    }
                
            case .empty, .failure(_):
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorConstant.bgContent)
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.clear)
                            .stroke(
                                calendarViewModel.isSelectedDate(day: day) ?
                                ColorConstant.accent : calendarViewModel.isToday(day: day) ?
                                ColorConstant.fgPrimary : Color.clear,
                                
                                lineWidth: 4
                            )
                        
                        Text(day, format: .number)
                            .fontWeight(.bold)
                    }
                    .onTapGesture {
                        calendarViewModel.selectDate(day: day)
                    }
            @unknown default:
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorConstant.bgContent)
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.clear)
                            .stroke(
                                calendarViewModel.isSelectedDate(day: day) ?
                                ColorConstant.accent : calendarViewModel.isToday(day: day) ?
                                ColorConstant.fgPrimary : Color.clear,
                                
                                lineWidth: 4
                            )
                        
                        Text(day, format: .number)
                            .fontWeight(.bold)
                    }
                    .onTapGesture {
                        calendarViewModel.selectDate(day: day)
                    }
            }
        }
    }
        
    private func getRepresentativeImageURL() -> URL? {
        // dailyMemory
        if let dailyMemory = dailyMemoryViewModel.getMemory(from: currentDate),
           let imageURL = dailyMemory.photosURL.first {
            return URL(string: imageURL)
        }
        
        
        // dogWalkingMemory
        let dogWalkingMemories = dogWalkingMemoryViewModel.getMemories(from: currentDate).wrappedValue
        if dogWalkingMemories.isEmpty == false {
            
            for memory in dogWalkingMemories where memory.markers.isEmpty == false {
                if let markerWithImageURL = memory.markers.first(where: { $0.imageURL != nil }) {
                    return URL(string: markerWithImageURL.imageURL ?? "")
                }
            }
        }
        
        return nil
    }
    
    private var currentDate: Date {
        let currentPageDate = calendarViewModel.currentPageDate
        let currentPageComponents = Calendar.current.dateComponents([.year, .month], from: currentPageDate)
        
        var dateComponents = DateComponents()
        dateComponents.year = currentPageComponents.year
        dateComponents.month = currentPageComponents.month
        dateComponents.day = day
        
        
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
}

#Preview {
    CalendarView()
}
