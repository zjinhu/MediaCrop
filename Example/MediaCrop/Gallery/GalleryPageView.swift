//
//  SwiftUIView.swift
//  
//
//  Created by HU on 2024/4/25.
//

import SwiftUI
import PagerTabStripView
import Photos
import BrickKit

struct GalleryPageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isNavigationQuickLook = false
    @State var selection = 0
    let maxSelectionCount: Int
    @StateObject var viewModel = GalleryModel()
    @Binding var selected: [SelectedAsset]

    let onlyImage: Bool
    let autoCrop: Bool
    let cropRatio: CGSize
    let selectTitle: String?
    
    init(maxSelectionCount: Int = 0,
         selectTitle: String? = nil,
         autoCrop: Bool = false,
         cropRatio: CGSize = .zero,
         onlyImage: Bool = false,
         selected: Binding<[SelectedAsset]>) {
        _selected = selected
        self.maxSelectionCount = maxSelectionCount
        self.autoCrop = autoCrop
        self.onlyImage = onlyImage
        self.cropRatio = cropRatio
        self.selectTitle = selectTitle
    }
    
    var body: some View {
        NavigationView {
            VStack{
                
                if viewModel.permission == .limited {
                    HStack {
                        Text("你已允许访问选择照片，可管理选择更多照片")
                            .font(.f12)
                            .foregroundColor(.secondGray)
                        
                        Spacer()
                        
                        Button {
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        } label: {
                            Text("管理")
                                .font(.f12)
                                .foregroundColor(.textColor)
                                .padding(.horizontal, 10)
                        }
                        .frame(height: 26)
                        .ss.border(Color.textColor, cornerRadius: 13, lineWidth: 1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 9)
                    .background(.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                }

                if viewModel.albums.isEmpty{
                    ProgressView()
                }
                
                PagerTabStripView(selection: $selection) {
                    
                    ForEach(viewModel.albums) { album in
                        GalleryView(album: album)
                            .pagerTabItem {
                                PageTitleView(title: album.title ?? "")
                            }
                            .environmentObject(viewModel)
                    }
                    
                }
                .frame(alignment: .center)
                .pagerTabStripViewStyle(.liner(indicatorBarHeight: 2,
                                               indicatorPadding: 5,
                                               indicatorBarColor: Color.textColor,
                                               padding: EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0),
                                               tabItemSpacing: 30,
                                               tabItemHeight: 30,
                                               placedInToolbar: true))
                
                if maxSelectionCount != 1{
                    HStack{

                        Spacer()
                        
                        Button {
                            for item in viewModel.selectedAssets{
                                var isImage = false
                                if viewModel.isStatic{
                                    isImage = true
                                }
                                if viewModel.tempStatic{
                                    isImage = true
                                }
                                item.isStatic = isImage
                            }
                            selected = viewModel.selectedAssets
                            dismiss()
                        } label: {
                            Text(doneButtonTitle())
                                .font(.f15)
                                .foregroundColor(.white)
                                .padding(.horizontal , 10)
                                .padding(.vertical, 10)
                                .background(viewModel.selectedAssets.count == 0 ? .gray : .black)
                                .cornerRadius(8)
                        }
                        .disabled(viewModel.selectedAssets.count == 0)
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 50)
                    .background(Color.backColor)
                    .shadow(color: .gray.opacity(0.2), radius: 0.5, y: -0.8)
                }

            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .maxHeight(12)
                            .foregroundColor(Color.textColor)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.maxSelectionCount = maxSelectionCount
            viewModel.isStatic = onlyImage
            viewModel.autoCrop = autoCrop
            viewModel.cropRatio = cropRatio
        }
        .ss.task {
            await viewModel.loadAllAlbums()
            await MainActor.run {
                if let selectTitle{
                    let index = viewModel.albums.firstIndex { item in
                        item.title == selectTitle
                    } ?? 0
                    
                    selection = index
                }
            }
        }
        .onChange(of: viewModel.onSelectedDone) { value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                selected = viewModel.selectedAssets
                dismiss()
            }
        }
        .toast(isPresenting: $viewModel.showToast){
    
            AlertToast(displayMode: .hud,
                       type: .systemImage("exclamationmark.circle.fill", .alertOrange),
                       title: "最多可选\(viewModel.maxSelectionCount)张照片",
                       style: .style(backgroundColor: .backColor, titleColor: .textColor, titleFont: .f14))
        }

    }
    
    func doneButtonTitle() -> String{
        let title = "完成"
        if viewModel.selectedAssets.count != 0{
            return title + "(\(viewModel.selectedAssets.count))"
        }
        return title
    }
}
