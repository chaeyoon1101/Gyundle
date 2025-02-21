//
//  DailyMemoryDetailView.swift
//  Gyundle
//
//  Created by 임채윤 on 1/2/25.
//

import SwiftUI

struct DailyMemoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dailyMemoryViewModel: DailyMemoryViewModel
    
    @State private var showDeleteConfirmation: Bool = false
    @State private var showEditView: Bool = false
    
    var memory: DailyMemory
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical) {
                    VStack {
                        if !memory.photosURL.isEmpty {
                            PhotoGridView(photosURL: memory.photosURL)
                                .frame(height: getScreenWidth() / CGFloat(memory.photosURL.count) - 4)
                        }
                        
                        Text(memory.text)
                            .align(.leading)
                            .padding()
                    }
                    .navigationTitle(memory.date.formatting("M월 d일의 기억"))
                    .navigationBarTitleDisplayMode(.inline)
                }
                .padding(4)
            }
            .toolbarRole(.editor)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ExtraButton()
                }
            }
            .fullScreenCover(isPresented: $showEditView) {
                DailyMemorizeView(memory: memory, isUpdating: true)
            }
            .toastView(
                isShowing: $dailyMemoryViewModel.showError,
                message: dailyMemoryViewModel.errorMessage
            )
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
                        await dailyMemoryViewModel.deleteMemory(memory, onSuccess: {
                            dismiss()
                        })
                    }
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
            showEditView = true
        } label: {
            Label("편집", systemImage: "pencil")
        }
    }
}

#Preview {
    HomeView(showMemorizeView: .constant(false))
        .environmentObject(AuthViewModel())
}
