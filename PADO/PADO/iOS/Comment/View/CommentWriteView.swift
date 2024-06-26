//
//  CommentWriteView.swift
//  PADO
//
//  Created by 강치우 on 2/10/24.
//

import SwiftUI

struct CommentWriteView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var commentVM: CommentViewModel
    
    @State var notiUser: User

    @FocusState private var isTextFieldFocused: Bool
    
    @Binding var post: Post
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("취소")
                        .font(.system(.body))
                        .fontWeight(.medium)
                }
                
                Spacer()
               
                Text("댓글 달기")
                    .font(.system(.body))
                    .fontWeight(.semibold)
                    .padding(.trailing, 30)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 15)
            
            Divider()
            
            ScrollView {
                ScrollViewReader { value in
                    VStack(alignment: .leading) {
                        if !commentVM.comments.isEmpty {
                            ForEach(commentVM.comments.indices, id:\.self) { index in
                                CommentWriteViewCell(commentVM: commentVM,
                                                     post: $post,
                                                     index: index)
                                .id(index)
                            }
                            .task {
                                try? await Task.sleep(nanoseconds: 1 * 700_000_000)
                                if let lastCommentID = commentVM.comments.last?.id {
                                    withAnimation {
                                        value.scrollTo(lastCommentID, anchor: .bottom)
                                    }
                                }
                            }
                        } else {
                            VStack {
                                Text("아직 댓글이 없습니다.")
                                    .font(.system(.body, weight: .semibold))
                                    .padding(.bottom, 10)
                                    .padding(.top, 120)
                                Text("댓글을 남겨보세요.")
                                    .font(.system(.footnote))
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .padding(.bottom, 6)
            
            Divider()
            
            HStack {
                if let user = viewModel.currentUser {
                    CircularImageView(size: .small, user: user)
                }
                
                HStack {
                    TextField("\(userNameID)(으)로 댓글 남기기...", text: $commentVM.commentText, axis: .vertical)
                        .font(.system(.body))
                        .tint(Color(.systemBlue).opacity(0.7))
                        .focused($isTextFieldFocused)
                        .onAppear {
                            self.isTextFieldFocused = true
                        }
                    
                    if !commentVM.commentText.isEmpty {
                        Button {
                            Task {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                
                                if let postID = post.id {
                                    await UpdatePushNotiData.shared.pushPostNoti(targetPostID: postID,
                                                                                 receiveUser: notiUser,
                                                                                 type: .comment,
                                                                                 message: commentVM.commentText,
                                                                                 post: post)
                                    await commentVM.writeComment(post: post,
                                                                                   imageUrl: viewModel.currentUser?.profileImageUrl ?? "",
                                                                 inputcomment: commentVM.commentText)
                                    
                                    commentVM.commentText = ""
                                }
                                dismiss()
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 26)
                                    .frame(width: 48, height: 28)
                                    .foregroundStyle(.blue)
                                Image(systemName: "arrow.up")
                                    .font(.system(.subheadline))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.vertical, -5)
                    } else {
                        Button {
                            //
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 26)
                                    .frame(width: 48, height: 28)
                                    .foregroundStyle(.gray)
                                Image(systemName: "arrow.up")
                                    .font(.system(.subheadline))
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                }
            }
            .padding([.horizontal, .vertical], 8)
        }
        .background(.main, ignoresSafeAreaEdges: .all)
    }
}
