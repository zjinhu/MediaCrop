//
//  File.swift
//  
//
//  Created by FunWidget on 2024/6/4.
//

import UIKit
import Photos

public struct MediaAsset{
    /// edit object
    /// 编辑对象
    public let mediaType: AssetType
    
    /// edit result
    /// 编辑结果
    public var mediaResult: MediaResult?
    
    public init(type: AssetType, result: MediaResult? = nil) {
        self.mediaType = type
        self.mediaResult = result
    }
}

extension MediaAsset {
    public enum AssetType {
        case image(UIImage)
        case imageData(Data)
        case video(URL)
        case livePhoto(URL)
        case gif(URL)
    }
}

public enum MediaResult {
    case image(UIImage, Data)
    case imageData(UIImage, Data)
    case video(URL)
    case gif(Data)
    case livePhoto(PHLivePhoto)
    
    public var image: UIImage? {
        switch self {
        case .image(let image, _):
            return image
        default:
            return nil
        }
    }
    
    public var imageData: Data? {
        switch self {
        case .image(_, let data):
            return data
        default:
            return nil
        }
    }
    
    public var videoURL: URL? {
        switch self {
        case .video(let url):
            return url
        default:
            return nil
        }
    }
    
    public var gifData: Data? {
        switch self {
        case .gif(let data):
            return data
        default:
            return nil
        }
    }
    
    public var livePhoto: PHLivePhoto? {
        switch self {
        case .livePhoto(let livePhoto):
            return livePhoto
        default:
            return nil
        }
    }
}
