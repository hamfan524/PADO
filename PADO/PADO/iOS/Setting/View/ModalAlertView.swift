//
//  ModalAlertView.swift
//  PADO
//
//  Created by 황민채 on 1/16/24.
//
import SwiftUI

// MARK: - DummyView 처럼 불러서 사용
enum ModalAlertTitle: String {
    case cash = "캐시 지우기"
    case account = "계정 삭제"
    case follower = ""
}

enum ModalAlertSubTitle: String {
    case cash = "캐시를 지우면 몇몇의 문제가 해결될 수 있어요"
    case account = "한번 삭제된 계정은 복원되지 않습니다. 정말 삭제하시겠습니까?"
    case follower = "팔로워에서 삭제하시겠어요?"
}

enum ModalAlertRemove: String {
    case cash = "PADO 캐시 지우기"
    case account = "계정 삭제"
    case follower = "삭제"
}

struct ModalAlertView: View {
    @State var width = UIScreen.main.bounds.width
    @State var height = UIScreen.main.bounds.height
    
    var showingCircleImage: Bool
    let mainTitle: ModalAlertTitle
    let subTitle: ModalAlertSubTitle
    let removeMessage: ModalAlertRemove
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                VStack(spacing: 10) {
                    if showingCircleImage {
                        CircularImageView(size: .medium)
                    } else {
                        Text(mainTitle.rawValue)
                    }
                    Text(subTitle.rawValue)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(Color.black)
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .padding(30)
                
                Divider()
                
                Button {
                    
                } label: {
                    Text(removeMessage.rawValue)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.red)
                        .fontWeight(.semibold)
                        .frame(width: width * 0.9, height: 40)
                }
                .padding(.bottom, 5)
            }
            .frame(width: width * 0.9)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 25))
            
            VStack {
                Button {
                    dismiss()
                } label: {
                    Text("취소")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.black)
                        .fontWeight(.semibold)
                        .frame(width: width * 0.9, height: 40)
                }
            }
            .frame(width: width * 0.9, height: 50)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 15))
        }
        .background(ClearBackground())
    }
}

//#Preview {
//    ModalAlertView()
//}