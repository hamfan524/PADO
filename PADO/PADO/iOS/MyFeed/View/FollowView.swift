//
//  FollowView.swift
//  PADO
//
//  Created by 황성진 on 1/16/24.
//

import SwiftUI

struct FollowView: View {
    // MARK: - PROPERTY
    @State var width = UIScreen.main.bounds.width
    @State var menu = "following"
    
    // MARK: - BODY
    var body: some View {
        VStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                
                if menu == "following" {
                    FollowingView()
                } else if menu == "follower" {
                    FollowerView()
                }
                
                VStack {
                    Spacer()
                    ZStack {
                        VStack {
                            ZStack {
                                Rectangle()
                                    .frame(width: 185, height: 44)
                                    .cornerRadius(25)
                                    .foregroundStyle(Color(.systemGray6))
                                
                                HStack(spacing: 4) {
                                    Rectangle()
                                        .frame(width: 71, height: 32)
                                        .foregroundStyle(Color("grayButtonColor"))
                                        .cornerRadius(25)
                                        .opacity(menu == "following" ? 1: 0)
                                        .overlay {
                                            Text("팔로잉")
                                                .foregroundStyle(.white)
                                                .font(.system(size: 14, weight: .semibold))
                                        }
                                        .onTapGesture {
                                            self.menu = "following"
                                        }
                                    
                                    Rectangle()
                                        .frame(width: 71, height: 32)
                                        .foregroundStyle(Color("grayButtonColor"))
                                        .cornerRadius(25)
                                        .opacity(menu == "follower" ? 1: 0)
                                        .overlay {
                                            Text("팔로워")
                                                .foregroundStyle(.white)
                                                .font(.system(size: 14, weight: .semibold))
                                        }
                                        .onTapGesture {
                                            self.menu = "follower"
                                        }
                                } //: HSTACK
                            } //: ZSTACK
                        } //: VSTACK
                        .zIndex(1)

                    } //: ZSTACK
                }
            }
        }
    }
}

#Preview {
    FollowView()
}
