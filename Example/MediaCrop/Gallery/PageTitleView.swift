//
//  SwiftUIView.swift
//  
//
//  Created by HU on 2024/4/25.
//

import SwiftUI
import PagerTabStripView

private class TitleTheme: ObservableObject {
    @Published var textColor = Color.secondGray
}

struct PageTitleView: View, PagerTabViewDelegate {
    let title: String
    @ObservedObject fileprivate var theme = TitleTheme()
    
    var body: some View {
        VStack {
            Text(title)
                .foregroundColor(theme.textColor)
                .font(.f15)
                .fontWeight(.medium)
        }
        .background(Color.clear)
    }
    
    func setState(state: PagerTabViewState) {
        switch state {
        case .selected:
            self.theme.textColor = .textColor
        case .highlighted:
            self.theme.textColor = .textColor
        default:
            self.theme.textColor = .secondGray
        }
    }
}

#Preview {
    PageTitleView(title: "123")
}
