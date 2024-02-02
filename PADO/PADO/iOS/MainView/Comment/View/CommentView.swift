//
//  CommentView.swift
//  PADO
//
//  Created by 최동호 on 1/16/24.
//

import SwiftUI

struct CommentView: View {
    @State var width = UIScreen.main.bounds.width
    
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @ObservedObject var feedVM: FeedViewModel
    @ObservedObject var surfingVM: SurfingViewModel
    
    @State private var commentText: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Text("댓글")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 14) {
                        
                        Divider()
                        
                        FaceMojiView(feedVM: feedVM, surfingVM: surfingVM)
                            .padding(2)
                        
                        Divider()
                    }
                    .padding(.top, 5)
                    
                    Spacer()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading) {
                            if feedVM.comments.isEmpty {
                                VStack {
                                    Text("아직 댓글이 없습니다.")
                                        .font(.system(size: 16, weight: .semibold))
                                        .padding(.bottom, 10)
                                        .padding(.top, 120)
                                    Text("댓글을 남겨보세요.")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.gray)
                                }
                            } else {
                                ForEach(feedVM.comments) { comment in
                                    CommentCell(comment: comment, feedVM: feedVM)
                                        .padding(.horizontal, 10)
                                        .padding(.bottom, 20)
                                }
                            }
                        }
                        .padding(.top)
                    }
                    .offset(y: -7)
                    
                    Spacer()
                    
                    Divider()
                        .offset(y: -14)
                    ZStack {
                        HStack {
                            if let user = viewModel.currentUser {
                                CircularImageView(size: .medium, user: user)
                            }
                            ZStack {
                                VStack {
                                    HStack {
                                        TextField("\(userNameID)(으)로 댓글 달기...",
                                                  text: $commentText,
                                                  axis: .vertical) // 세로 축으로 동적 높이 조절 활성화
                                        .font(.system(size: 12))
                                        .tint(Color(.systemBlue))
                                        
                                        if !commentText.isEmpty {
                                            Button {
                                                Task {
                                                    await feedVM.writeComment(inputcomment: commentText)
                                                    commentText = ""
                                                    await feedVM.getCommentsDocument()
                                                }
                                            } label: {
                                                Image(systemName: "paperplane.fill")
                                                    .resizable()
                                                    .frame(width: 18, height: 18)
                                                    .foregroundStyle(Color(.systemBlue))
                                                    .bold()
                                            }
                                            .padding(.vertical, -5)
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 30) // HStack의 크기에 맞게 동적으로 크기가 변하는 RoundedRectangle
                                        .stroke(Color(.systemGray5), lineWidth: 1)
                                )
                                
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                }
                .padding(.top, 30)
            }
            .onAppear {
                Task {
                    try await feedVM.getFaceMoji()
                }
            }
        }
    }
}

