import SwiftUI

public extension View {
    
    /// Customize albums to take screenshots after selecting photos
    /// - Parameters:
    ///   - isPresented: view state 弹窗页面状态
    ///   - cropVideoTime: Set the maximum cropping time 设置最大裁剪时长
    ///   - cropVideoFixTime: Can you manually adjust the cutting duration 是否可以手动调整裁剪时长
    ///   - cropRatio: Crop ratio, width height 设置裁剪比例
    ///   - asset: SelectedAsset 资源文件
    ///   - returnAsset: Return the cropped result 返回修改后的model
    /// - Returns: description
    @ViewBuilder func mediaCrop(isPresented: Binding<Bool>,
                                cropVideoTime: TimeInterval = 5,
                                cropVideoFixTime: Bool = false,
                                cropRatio: CGSize = .zero,
                                asset: MediaAsset?,
                                returnAsset: @escaping (MediaAsset) -> Void) -> some View {
        
        fullScreenCover(isPresented: isPresented) {
            if let asset {
                EditView(asset: asset,
                         cropVideoTime: cropVideoTime,
                         cropVideoFixTime: cropVideoFixTime,
                         cropRatio: cropRatio,
                         done: returnAsset)
                .statusBar(hidden: true)
                .ignoresSafeArea()
                
            }else{
                EmptyView()
            }
        }
    }
    
}
