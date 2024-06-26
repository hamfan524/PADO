//
//  SettingProfileModal.swift
//  PADO
//
//  Created by 황성진 on 2/5/24.
//

import PhotosUI
import SwiftUI

struct SettingProfileModal: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    @Binding var isActive: Bool
    
    var body: some View {
        VStack {
            Button {
                viewModel.showProfileModal = false
            } label: {
                PhotosPicker(selection: $viewModel.selectedItem,
                             matching: .images) {
                    Text("프로필 사진 변경")
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 45)
                        .background(.modalCell)
                        .cornerRadius(10)
                        .padding(.vertical, 5)
                }
            }
            
            Button {
                viewModel.showProfileModal = false
            } label: {
                PhotosPicker(selection: $viewModel.selectedBackgroundItem,
                             matching: .images) {
                    Text("배경 사진 변경")
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 45)
                        .background(.modalCell)
                        .cornerRadius(10)
                        .padding(.vertical, 5)
                }
            }
            
            Button {
                viewModel.showProfileModal = false
                viewModel.tempProfileImage = viewModel.currentUser?.profileImageUrl
                viewModel.currentUser?.profileImageUrl = nil
                isActive = true
            } label: {
                Text("프로필 사진 초기화")
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(.red)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 45)
                    .background(.modalCell)
                    .cornerRadius(10)
                    .padding(.vertical, 5)
            }
            
            Button {
                viewModel.showProfileModal = false
                viewModel.tempBackImage = viewModel.currentUser?.backProfileImageUrl
                viewModel.currentUser?.backProfileImageUrl = nil
                isActive = true
            } label: {
                Text("배경 사진 초기화")
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(.red)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 45)
                    .background(.modalCell)
                    .cornerRadius(10)
                    .padding(.vertical, 5)
            }
        }
    }
}

