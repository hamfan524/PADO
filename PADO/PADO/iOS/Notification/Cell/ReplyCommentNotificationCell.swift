//
//  ReplyCommentNotificationCell.swift
//  PADO
//
//  Created by 최동호 on 2/27/24.
//

import Kingfisher
import SwiftUI

struct ReplyCommentNotificationCell: View {
    @ObservedObject var notiVM: NotificationViewModel
    
    var notification: Noti
    
    var body: some View {
        Button {
            notiVM.showReplyCommentPost = true
        } label: {
            HStack(spacing: 0) {
                if let user = notiVM.notiUser[notification.sendUser] {
                    CircularImageView(size: .medium,
                                           user: user)
                    .padding(.trailing, 10)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(notification.sendUser)님의 회원님의 댓글에 답글을 남겼습니다: \(notification.message ?? "") ")
                            .font(.system(.subheadline))
                            .fontWeight(.medium)
                        +
                        Text(notification.createdAt.formatDate(notification.createdAt))
                            .font(.system(.footnote))
                            .foregroundStyle(Color(.systemGray))
                    }
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $notiVM.showReplyCommentPost) {
            if let postID = notification.postID,
               let post = notiVM.notiPosts[postID] {
                NavigationStack {
                    FeedCell(post: .constant(post))
                    .presentationDragIndicator(.visible)
                }
            }
        }
    }
}
