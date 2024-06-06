import SwiftUI
import UIKit
import ImageIO
import AVFoundation
import MediaCrop
public struct GIFView: UIViewRepresentable {
    private let data: Data
    private let repetitions: Int
    
    public init(
        data: Data,
        repetitions: Int = 0
    ) {
        self.data = data
        self.repetitions = repetitions
    }
    
    public func makeUIView(context: Context) -> UIGIFImageView {
        return UIGIFImageView(data: data, repetitions: repetitions)
    }
    
    public func updateUIView(_ uiView: UIGIFImageView, context: Context) {
        uiView.setImageData(data: data, repetitions: repetitions)
    }
}

public class UIGIFImageView: UIImageView {

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.contentMode = .scaleAspectFit
    }
    
    convenience init(data: Data, repetitions: Int = 0) {
        self.init(frame: .zero)
        
        if let animation = UIImage.animatedImage(withData: data) {
            self.animationImages = animation.images
            self.animationDuration = animation.duration
            self.animationRepeatCount = repetitions
            self.image = animation.images?.last
            self.startAnimating()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImageData(data: Data,
                      repetitions: Int = 0){
        if let animation = UIImage.animatedImage(withData: data) {
            self.animationImages = animation.images
            self.animationDuration = animation.duration
            self.animationRepeatCount = repetitions
            self.image = animation.images?.last
            self.startAnimating()
        }
    }
    
}
