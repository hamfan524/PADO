//
//  GridDetailView.swift
//  PADO
//
//  Created by 강치우 on 2/7/24.
//

import Kingfisher
import SwiftUI

enum PostViewType {
    case receive
    case send
    case highlight
}

struct SelectPostView: View {
    @ObservedObject var profileVM: ProfileViewModel

    let updateHeartData = UpdateHeartData()
    var viewType: PostViewType
    
    @Binding var isShowingDetail: Bool
    @GestureState private var dragState = CGSize.zero
    
    var selectedPostID: String
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                ScrollViewReader { value in
                    switch viewType {
                    case .receive:
                        ForEach(profileVM.padoPosts.indices, id: \.self) { index in
                            OtherSelectPostCell(profileVM: profileVM,
                                                updateHeartData: updateHeartData,
                                                post: $profileVM.padoPosts[index],
                                                cellType: .receive)
                                .id(index)
                        }
                        .onAppear {
                            value.scrollTo(selectedPostID, anchor: .top)
                        }
                    case .send:
                        ForEach(profileVM.sendPadoPosts.indices, id: \.self) { index in
                            OtherSelectPostCell(profileVM: profileVM,
                                                updateHeartData: updateHeartData,
                                                post: $profileVM.sendPadoPosts[index],
                                                cellType: .receive)
                                .id(index)
                        }
                        .onAppear {
                            value.scrollTo(selectedPostID, anchor: .top)
                        }
                    case .highlight:
                        ForEach(profileVM.highlights.indices, id: \.self) { index in
                            OtherSelectPostCell(profileVM: profileVM,
                                                updateHeartData: updateHeartData,
                                                post: $profileVM.highlights[index],
                                                cellType: .receive)
                                .id(index)
                        }
                        .onAppear {
                            value.scrollTo(selectedPostID, anchor: .top)
                        }
                    }
                    
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .ignoresSafeArea()
            
            VStack {
                HStack(alignment: .top) {
                    Button {
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                            self.isShowingDetail = false
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18))
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Text(titleForType(viewType))
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                        .padding(.trailing, 15)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .gesture(
            DragGesture()
                .updating($dragState) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    if value.translation.height > 100 || abs(value.translation.width) > 100 {
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                            isShowingDetail = false // 드래그가 일정 임계값을 넘어서면 뷰 닫기
                        }
                    }
                }
        )
    }
    
    // 각 뷰 타입에 맞는 제목 반환
    private func titleForType(_ type: PostViewType) -> String {
        switch type {
        case .receive:
            return "받은 파도"
        case .send:
            return "보낸 파도"
        case .highlight:
            return "하이라이트"
        }
    }
}
