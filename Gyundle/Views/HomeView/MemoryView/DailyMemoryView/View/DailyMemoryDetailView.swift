//
//  DailyMemoryDetailView.swift
//  Gyundle
//
//  Created by 임채윤 on 1/2/25.
//

import SwiftUI

struct DailyMemoryDetailView: View {
    @EnvironmentObject var dailyMemoryViewModel: DailyMemoryViewModel
    
    @Binding var isPresented: Bool
    
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical) {
                    
                    if let memory = dailyMemoryViewModel.selectedMemory {
                        VStack {
                            if !memory.photos.isEmpty {
                                PhotoGridView(photosURL: memory.photos)
                                    .frame(height: getScreenWidth() / CGFloat(memory.photos.count) - 4)
                            }
                            
                            Text(memory.text)
                                .align(.leading)
                                .padding()
                        }
                        .navigationTitle(memory.date.formatting("M월 d일의 기억"))
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
                .padding(4)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(ColorConstant.fgSecondary)
                            .fontWeight(.bold)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    ExtraButton()
                }
            }
        }
    }
    
    @ViewBuilder
    func ExtraButton() -> some View {
        Menu {
            EditButton()
            
            DeleteButton()
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(ColorConstant.fgPrimary)
                .fontWeight(.bold)
        }
        .confirmationDialog(
            "삭제 확인 알림",
            isPresented: $showDeleteConfirmation,
            actions: {
                Button("취소", role: .cancel) {
                    print("취소")
                }
                
                Button("삭제하기", role: .destructive) {
                    Task {
                        await dailyMemoryViewModel.deleteMemory()
                    }
                    isPresented = false
                }
            },
            message: {
                Text("이 기억을 삭제하시겠습니까? 되돌릴 수 없습니다.")
            }
        )
    }
    
    @ViewBuilder
    func DeleteButton() -> some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Label("삭제", systemImage: "trash")
        }
    }
    
    @ViewBuilder
    func EditButton() -> some View {
        Button {
            isPresented = false
            dailyMemoryViewModel.isPresentedMemorizeView = true
        } label: {
            Label("편집", systemImage: "pencil")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(UserViewModel())
}
