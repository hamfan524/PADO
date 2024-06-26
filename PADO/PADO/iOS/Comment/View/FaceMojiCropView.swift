//
//  PhotoMojiCropView.swift
//  PADO
//
//  Created by 황성진 on 2/4/24.
//

import PhotosUI
import SwiftUI

struct PhotoMojiCropView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var commentVM: CommentViewModel
    
    // 이미지 조작을 위한 상태 변수들
    @GestureState private var isInteractig: Bool = false
    
    @Binding var postOwner: User
    @Binding var post: Post
    
    let postID: String
    let updatePhotoMojiData: UpdatePhotoMojiData
    var crop: Crop = .circle
    var onCrop: (UIImage?, Bool) -> Void
    
    var body: some View {
        imageView()
            .navigationTitle("편집")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.main, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.main
                    .ignoresSafeArea()
            }
            .navigationDestination(isPresented: $commentVM.showEmojiView) {
                SelectEmojiView(commentVM: commentVM,
                                postOwner: $postOwner,
                                post: $post, 
                                postID: postID, 
                                updatePhotoMojiData: updatePhotoMojiData)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let renderer = ImageRenderer(content: imageView(true))
                        renderer.scale = 3
                        renderer.proposedSize = .init(crop.size())
                        if let image = renderer.uiImage {
                            onCrop(image, true)
                            commentVM.cropMojiUIImage = image
                            commentVM.cropMojiImage = Image(uiImage: image)
                        } else {
                            onCrop(nil, false)
                        }
                        commentVM.showEmojiView = true
                    } label: {
                        Text("이모지 선택")
                            .font(.system(.body, weight: .semibold))
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        commentVM.showCropPhotoMoji = false
                    } label: {
                        Image("dismissArrow")
                    }
                }
            }
    }
    
    // 이미지 뷰를 구성하는 함수
    // 이미지 뷰는 이전 화면에서 선택한 이미지
    @ViewBuilder
    func imageView(_ hideGrids: Bool = false) -> some View {
        let cropSize = crop.size()
        GeometryReader {
            let size = $0.size
            
            if let image = commentVM.photoMojiUIImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(content: {
                        GeometryReader { proxy in
                            let rect = proxy.frame(in: .named("CROPVIEW"))
                            
                            Color.clear
                                .onChange(of: isInteractig) { oldValue, newValue in
                                    // 드래그, 핀치 제스처 에 대한 내용
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if rect.minX > 0 {
                                            commentVM.offset.width = (commentVM.offset.width - rect.minX)
                                            haptics(.medium)
                                        }
                                        if rect.minY > 0 {
                                            commentVM.offset.height = (commentVM.offset.height - rect.minY)
                                            haptics(.medium)
                                        }
                                        if rect.maxX < size.width {
                                            commentVM.offset.width = (rect.minX - commentVM.offset.width)
                                            haptics(.medium)
                                        }
                                        
                                        if rect.maxY < size.height {
                                            commentVM.offset.height = (rect.minY - commentVM.offset.height)
                                            haptics(.medium)
                                        }
                                    }
                                    if !newValue {
                                        commentVM.lastStoredOffset = commentVM.offset
                                    }
                                }
                        }
                    })
                    .frame(size)
            }
        }
        .scaleEffect(commentVM.scale)
        .offset(commentVM.offset)
        // 그리드를 보여주는 곳
        .overlay(content: {
            if !hideGrids {
                if commentVM.showinGrid {
                    ImageGrid(isShowinRectangele: false)
                }
            }
        })
        .coordinateSpace(name: "CROPVIEW")
        // 드래그 제스쳐를 통해서 그리드를 보여주고 안보여줌
        .gesture(
            DragGesture()
                .updating($isInteractig, body: { _, out, _ in
                    out = true
                }).onChanged({ value in
                    let translation = value.translation
                    commentVM.offset = CGSize(width: translation.width + commentVM.lastStoredOffset.width, height: translation.height + commentVM.lastStoredOffset.height)
                    commentVM.showinGrid = true
                })
                .onEnded({ value in
                    commentVM.showinGrid = false
                })
        )
        .gesture(
            MagnificationGesture()
                .updating($isInteractig, body: { _, out, _ in
                    out = true
                }).onChanged({ value in
                    let updatedScale = value + commentVM.lastScale
                    // - Limiting Beyound 1
                    commentVM.scale = (updatedScale < 1 ? 1 : updatedScale)
                }).onEnded({ value in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if commentVM.scale < 1 {
                            commentVM.scale = 1
                            commentVM.lastScale = 0
                        } else {
                            commentVM.lastScale = commentVM.scale - 1
                        }
                    }
                })
        )
        .frame(cropSize)
        .clipShape(RoundedRectangle(cornerRadius: crop == .circle ? cropSize.height / 2 : 0))
    }
}
