//
//  ProfileCell.swift
//  PADO
//
//  Created by 강치우 on 1/22/24.
//

import SwiftUI

struct ProfileCell: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @ObservedObject var followVM: FollowViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CircularImageView(size: .xxLarge)
            
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("@\(viewModel.currentUser?.nameID ?? "몰루")")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    
                    if let nickname = viewModel.currentUser?.username {
                        Text(nickname)
                    }
                }
                
                Spacer()
                
                NavigationLink(destination: SettingProfileView()) {
                    ZStack {
                        RoundedRectangle(cornerRadius:4)
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(width: 78, height: 28)
                        Text("프로필 편집")
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                            .foregroundStyle(.gray)
                    }
                }
            }
            
            HStack {
                HStack(spacing: 5) {
                    Text("5")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text("wave time")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                Rectangle()
                    .foregroundStyle(Color(.systemGray2))
                    .frame(width: 1, height: 18)
                    .padding(.horizontal, 2)
                
                NavigationLink(destination: FollowView(followVM: followVM)) {
                    HStack(spacing: 5) {
                        Text("\(followVM.followerIDs.count + followVM.surferIDs.count)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        
                        Text("follower")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                
                Rectangle()
                    .foregroundStyle(Color(.systemGray2))
                    .frame(width: 1, height: 18)
                    .padding(.horizontal, 2)
                
                NavigationLink(destination: FollowView(followVM: followVM)) {
                    HStack(spacing: 5) {
                        Text("\(followVM.followingIDs.count)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Text("following")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
