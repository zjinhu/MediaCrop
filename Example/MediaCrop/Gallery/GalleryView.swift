//
//  GalleryView.swift
//  PhotoRooms
//
//  Created by HU on 2024/4/22.
//

import Photos
import SwiftUI
import BrickKit

let photoColumns: Int = 4
let gridSpace: CGFloat = 5
let gridSize = (Screen.width - gridSpace * CGFloat(photoColumns)) / CGFloat(photoColumns)

struct GalleryView: View {
    
    @EnvironmentObject var viewModel: GalleryModel
    
    let columns: [GridItem] = [GridItem](repeating: GridItem(.fixed(gridSize), spacing: gridSpace, alignment: .center), count: photoColumns)
    
    var album: AlbumItem
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                
                if album.count != 0, let array = album.result{
                    ForEach(0..<album.count, id: \.self) { index in
                        
                        ThumbnailView(asset: array[index])
                            .frame(height: gridSize)
                            .id(array[index].localIdentifier)
                            .environmentObject(viewModel)
                    }
                }
                
            }
            .padding(.horizontal , 5)
        }
        .onAppear {
            let fetchOptions = PHFetchOptions()
            fetchOptions.includeHiddenAssets = false
            
            if viewModel.isStatic {
                fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            }
            
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            album.fetchResult(options: fetchOptions)
        }
        
    }
}

public extension View {
    /// Customize the album to select photos
    /// - Parameters:
    ///   - isPresented: view state
    ///   - maxSelectionCount: Maximum number of selections 最大可选数量
    ///   - selectTitle: selectTitle 设置选中title
    ///   - autoCrop: maxSelectionCount == 1, Auto jump to crop photo 当最大可选数量为1时是否自动跳转裁剪
    ///   - cropRatio: Crop ratio, width height 裁剪比例
    ///   - onlyImage: Select photos only 只选择照片
    ///   - selected: Bind return result
    /// - Returns: description
    @ViewBuilder func galleryPicker(isPresented: Binding<Bool>,
                                    maxSelectionCount: Int = 0,
                                    selectTitle: String? = nil,
                                    autoCrop: Bool = false,
                                    cropRatio: CGSize = .zero,
                                    onlyImage: Bool = false,
                                    selected: Binding<[SelectedAsset]>) -> some View {
        fullScreenCover(isPresented: isPresented) {
            GalleryPageView(maxSelectionCount: maxSelectionCount,
                            selectTitle: selectTitle,
                            autoCrop: autoCrop,
                            cropRatio: cropRatio,
                            onlyImage: onlyImage,
                            selected: selected)
            .ignoresSafeArea()
        }
    }
}
