//
//  PadoRideViewModel.swift
//  PADO
//
//  Created by 황성진 on 2/7/24.
//

import Firebase
import FirebaseFirestore
import FirebaseStorage
import Kingfisher
import PencilKit
import PhotosUI
import SwiftUI

class PadoRideViewModel: ObservableObject {
    @Published var selectedImage: String = ""
    @Published var selectedUIImage: UIImage?
    @Published var postsData: [String: [Post]] = [:]
    
    @Published var selectedPost: Post?
    
    @Published var isShowingEditView: Bool = false
    @Published var isShowingDrawingView: Bool = false
    @Published var showingModal: Bool = false
    @Published var selectedPickerImage: Image = Image("")
    @Published var selectedPickerUIImage: UIImage = UIImage()
    
    @MainActor
    @Published var pickerImageItem: PhotosPickerItem? {
        didSet {
            Task {
                do {
                    let (loadedUIImage, loadedSwiftUIImage) = try await UpdateImageUrl.shared.loadImage(selectedItem: pickerImageItem)
                    self.selectedPickerUIImage = loadedUIImage
                    self.selectedPickerImage = loadedSwiftUIImage
                } catch {
                    print("이미지 로드 중 오류 발생: \(error)")
                }
            }
        }
    }
    
    // Pencil킷 관련 변수들
    @Published var canvas = PKCanvasView()
    @Published var toolPicker = PKToolPicker()
    @Published var textBoxes: [TextBox] = []
    @Published var imageBoxes: [ImageBox] = []
    @Published var addNewBox = false
    @Published var currentTextIndex: Int = 0
    @Published var currentImageIndex: Int = 0
    @Published var rect: CGRect = .zero
    @Published var decoUIImage: UIImage = UIImage()
    
    let getPostData = GetPostData()
    let cropWhiteBackground = CropWhiteBackground()
    let db = Firestore.firestore()
    
    // 선택된 이미지 URL을 기반으로 UIImage를 다운로드하고 저장하는 함수
    func downloadSelectedImage() {
        guard let url = URL(string: selectedImage) else { return }
        
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let imageResult):
                self.selectedUIImage = imageResult.image
                
            case .failure(let error):
                print(error)
                self.selectedUIImage = nil
            }
        }
    }
    
    func cancelImageEditing() {
        selectedUIImage = nil
        selectedImage = ""
        selectedPickerUIImage = UIImage()
        selectedPickerImage = Image("")
        decoUIImage = UIImage()
        canvas = PKCanvasView()
        toolPicker = PKToolPicker()
        textBoxes.removeAll()
        imageBoxes.removeAll()
        currentTextIndex = 0
        currentImageIndex = 0
        addNewBox = false
    }
    
    func calculateTextSize(text: String, font: UIFont, maxWidth: CGFloat) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let size = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let rect = text.boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return rect.size
    }
    
    // PhotosPickerItem에서 이미지 로드 및 처리
    func loadImageFromPickerItem(_ pickerItem: PhotosPickerItem?) {
        guard let pickerItem = pickerItem else { return }

        // 선택한 항목에서 이미지 데이터 로드
        pickerItem.loadTransferable(type: Data.self) { [weak self] result in
            switch result {
            case .success(let imageData):
                if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        // 이미지 데이터를 사용하여 ImageBox 생성 및 업데이트
                        let newImageBox = ImageBox(image: Image(uiImage: uiImage))
                        self?.imageBoxes.append(newImageBox)
                        self?.currentImageIndex = (self?.imageBoxes.count ?? 0) - 1
                    }
                }
            case .failure(let error):
                // 오류 처리
                print("이미지 로딩 실패: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func cancelTextView() async {
        
        self.toolPicker.setVisible(true, forFirstResponder: self.canvas)
        self.canvas.becomeFirstResponder()
        
        withAnimation {
            addNewBox = false
        }
        
        if textBoxes[currentTextIndex].isAdded {
            textBoxes.removeLast()
        }
    }
    
    // 특정 ID들에 대한 포스트 데이터를 미리 로드
    func preloadPostsData(for ids: [String]) async {
        for id in ids {
            let posts = await getPostData.suffingPostData(id: id)
            DispatchQueue.main.async {
                self.postsData[id] = posts
            }
        }
    }
    
    @MainActor
    func saveImage() {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        canvas.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        let makeUIView = ZStack {
            ForEach(textBoxes){[self] box in
                Text(textBoxes[currentTextIndex].id == box.id && addNewBox ? "" : box.text)
                    .font(.system(size: 30))
                    .fontWeight(box.isBold ? .bold : .none)
                    .foregroundColor(box.textColor)
                    .offset(box.offset)
            }
        }
        
        let controller = UIHostingController(rootView: makeUIView).view!
        controller.frame = rect
        
        controller.backgroundColor = .clear
        canvas.backgroundColor = .clear
        
        controller.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        if let image = generatedImage?.pngData(){
            
            UIImageWriteToSavedPhotosAlbum(UIImage(data: image)!, nil, nil, nil)
            selectedUIImage = UIImage(data: image) ?? UIImage()
            
            Task {
                let testdecoUIImage = try await cropWhiteBackground.processImage(inputImage: selectedUIImage ?? UIImage())
                
                let ratioTest = await ImageRatioResize.shared.resizeImage(testdecoUIImage, toSize: CGSize(width: 900, height: 1500))
                
                decoUIImage = ratioTest
            }
            
        }
    }
    
    func sendPostAtFirebase() async {
        let filename = "\(userNameID)-\(String(describing: selectedPost?.id ?? ""))"
        
        let storageRef = Storage.storage().reference(withPath: "/pado_ride/\(filename)")
        
        guard let imageData = decoUIImage.jpegData(compressionQuality: 1.0) else { return }
        
        do {
            _ = try await storageRef.putDataAsync(imageData)
            let url = try await storageRef.downloadURL()
            
            try await db.collection("post")
                .document(String(describing: selectedPost?.id ?? ""))
                .collection("padoride")
                .document(userNameID)
                .setData(
                    ["imageUrl" : url.absoluteString,
                     "storageFileName" : "\(userNameID)-\(String(describing: selectedPost?.id ?? ""))",
                     "time" : Timestamp()]
                )
            
        } catch {
            print("DEBUG: Failed to upload image with error: \(error.localizedDescription)")
        }
    }
}
