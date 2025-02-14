//
//  TitleView.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 12/08/2024.
//

import SwiftUI
import xpeho_ui

struct Title: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.raleway(.bold, size: 20))
            .foregroundStyle(XPEHO_THEME.CONTENT_COLOR)
            .frame(alignment: .leading)
    }
}

#Preview {
    Title(text: "Title")
}
