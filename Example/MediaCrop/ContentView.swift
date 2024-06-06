//
//  ContentView.swift
//  Example
//
//  Created by FunWidget on 2024/4/22.
//

import SwiftUI
import BrickKit
import MediaCrop
import AVFoundation
class SelectItem: ObservableObject{
    @Published var pictures: [SelectedAsset] = []
    @Published var selectedIndex = 0
    @Published var mediaAsset: MediaAsset?
}

struct ContentView: View {
    @State var isPresentedGallery = false
    @StateObject var selectItem = SelectItem()
    @State var isPresentedCrop = false
    var body: some View {
        VStack {
            Button {
                isPresentedGallery.toggle()
            } label: {
                Text("打开自定义相册SwiftUI")
                    .foregroundColor(Color.red)
                    .frame(height: 50)
            }
            .galleryPicker(isPresented: $isPresentedGallery,
                           maxSelectionCount: 6,
                           selectTitle: "Videos",
                           autoCrop: false,
                           cropRatio: .init(width: 1, height: 1),
                           onlyImage: false,
                           selected: $selectItem.pictures)
            List {

                if let picture = selectItem.mediaAsset?.mediaResult{
                    switch picture {
                    case .image(let uIImage, _):
                        Image(uiImage: uIImage)
                            .resizable()
                            .scaledToFit()
                    case .imageData(_, let data):
                        Image(uiImage: UIImage(data: data)!)
                            .resizable()
                    case .video(let uRL):
                        PlayerView(player: AVPlayer.init(playerItem: AVPlayerItem(url: uRL)))
                    case .gif(let data):
                        GIFView(data: data)
                    case .livePhoto(let pHLivePhoto):
                        LivePhotoView(livePhoto: pHLivePhoto)
                    }
                }

                
                ForEach(Array(selectItem.pictures.enumerated()), id: \.element) { index, picture in
                    
                    Button {
                        
                        ///在进入编辑页面之前需要准备好相关类型的资源，保证每次进入编辑都是最原始的状态
                        Task{
                            selectItem.selectedIndex = index
                            let asset = await picture.getOriginalSource()
                            
                            switch asset.assetType {
                            case .image:
                                if let image = asset.image{
                                    selectItem.mediaAsset = .init(type: .image(image))
                                    isPresentedCrop.toggle()
                                }
                            case .livePhoto:
                                if let url = asset.videoUrl{
                                    selectItem.mediaAsset = .init(type: .livePhoto(url))
                                    isPresentedCrop.toggle()
                                }
                            case .video:
                                if let url = asset.videoUrl{
                                    selectItem.mediaAsset = .init(type: .video(url))
                                    isPresentedCrop.toggle()
                                }
                            case .gif:
                                if let url = asset.videoUrl{
                                    selectItem.mediaAsset = .init(type: .gif(url))
                                    isPresentedCrop.toggle()
                                }
                            }
                        }
                        
                    } label: {
                        switch picture.fetchPHAssetType(){
                        case .gif:
                            QLGifView(asset: picture)
                        case .livePhoto:
                            QLivePhotoView(asset: picture)
                                .frame(height: Screen.width)
                        case .video:
                            QLVideoView(asset: picture)
                                .frame(height: 200)
                        default:
                            QLImageView(asset: picture)
                        }
                    }
                    
                }
                .id(UUID())
                
            }
        }
        .mediaCrop(isPresented: $isPresentedCrop,
                   asset: selectItem.mediaAsset) { asset in
            selectItem.mediaAsset = asset
        }
    }
}

#Preview {
    ContentView()
}
