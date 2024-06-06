//
//  SwiftUIView.swift
//
//
//  Created by HU on 2024/5/9.
//

import SwiftUI
import BrickKit
struct EditView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    let cropRatio: CGSize
    var selectedAsset: MediaAsset
    let editDone: (MediaAsset) -> Void
    let cropVideoTime: TimeInterval
    let cropVideoFixTime: Bool
    
    init(asset: MediaAsset,
         cropVideoTime: TimeInterval = 5,
         cropVideoFixTime: Bool = false,
         cropRatio: CGSize = .zero,
         done: @escaping (MediaAsset) -> Void) {
        
        self.cropRatio = cropRatio
        self.editDone = done
        self.cropVideoTime = cropVideoTime
        self.cropVideoFixTime = cropVideoFixTime
        self.selectedAsset = asset
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return makeCropper(context: context)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    func makeCropper(context: Context) -> UIViewController {
        
        var config = EditorConfiguration()
        config.isAutoBack = false
        config.isIgnoreCropTimeWhenFixedCropSizeState = false
        config.cropSize.isShowScaleSize = false
        config.video.cropTime.isCanControlMove = !cropVideoFixTime
        config.cropSize.maskType = .customColor(color: .black.withAlphaComponent(0.6))

        if cropRatio != .zero{
            config.cropSize.isFixedRatio = true
            config.cropSize.aspectRatio = cropRatio
        }else{
            config.cropSize.isFixedRatio = false
        }
        
        switch selectedAsset.mediaType {
        case .image(let image):
            let vc = EditViewController(.init(type: .image(image)), config: config)
            vc.delegate = context.coordinator
            return vc
        case .imageData(let data):
            let vc = EditViewController(.init(type: .imageData(data)), config: config)
            vc.delegate = context.coordinator
            return vc
        case .video(let url), .gif(let url):
            config.video.cropTime.minimumTime = 1
            config.video.cropTime.maximumTime = cropVideoTime
            let vc = EditViewController(.init(type: .video(url)), config: config)
            vc.delegate = context.coordinator
            return vc
        case .livePhoto(let url):
            config.video.cropTime.minimumTime = 1.5
            config.video.cropTime.maximumTime = max(1.5, cropVideoTime)
            let vc = EditViewController(.init(type: .video(url)), config: config)
            vc.delegate = context.coordinator
            return vc
        }

    }
    
    class Coordinator: EditViewControllerDelegate {
        var parent: EditView
        
        init(_ parent: EditView) {
            self.parent = parent
        }
        // MARK: - 编辑完成后制造数据
        /// 完成编辑
        /// - Parameters:
        ///   - editorViewController: 对应的 EditorViewController
        ///   - result: 编辑后的数据
        func editorViewController(_ editorViewController: EditViewController, didFinish asset: EditorAsset) {
            switch parent.selectedAsset.mediaType {
            case .image:
                if let imageURL = asset.result?.url,
                   let imageData = try? Data(contentsOf: imageURL),
                   let image = UIImage(data: imageData){
                    let result = MediaResult.image(image, imageData)
                    parent.selectedAsset.mediaResult = result
                    parent.editDone(parent.selectedAsset)
                    parent.dismiss()
                }
            case .imageData:
                if let imageURL = asset.result?.url,
                   let imageData = try? Data(contentsOf: imageURL),
                   let image = UIImage(data: imageData){
                    let result = MediaResult.image(image, imageData)
                    parent.selectedAsset.mediaResult = result
                    parent.editDone(parent.selectedAsset)
                    parent.dismiss()
                }
            case .video:
                if let videoUrl = asset.result?.url{
                    let result = MediaResult.video(videoUrl)
                    parent.selectedAsset.mediaResult = result
                    parent.editDone(parent.selectedAsset)
                    parent.dismiss()
                }
            case .livePhoto:
                if let videoUrl = asset.result?.url{
                    LivePhoto.generate(videoURL: videoUrl) { progress in
                        print("LivePhoto--\(progress)")
                    } completion: { live, res in
                        if let live{
                            let result = MediaResult.livePhoto(live)
                            self.parent.selectedAsset.mediaResult = result
                            self.parent.editDone(self.parent.selectedAsset)
                            self.parent.dismiss()
                        }
                    }
                }
            case .gif:
                if let videoUrl = asset.result?.url{
                    GifTool.createGifData(from: videoUrl) { date in
                        if let date{
                            let result = MediaResult.gif(date)
                            self.parent.selectedAsset.mediaResult = result
                            self.parent.editDone(self.parent.selectedAsset)
                            self.parent.dismiss()
                        }
                    }
                }
            }
        }
        
        func editorViewController(didCancel editorViewController: EditViewController) {
            parent.dismiss()
        }
        
    }
}

