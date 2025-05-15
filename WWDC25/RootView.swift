//
//  RootView.swift
//  WWDC25
//
//  Created by User@Param on 19/02/25.
//

import SwiftUI

struct RootView: View {
    @AppStorage("currentView") private var currentView: String = "LoginPageView"
    
    var body: some View {
        switch currentView {
        case "ContentView":
            ContentView() // ✅ No need to pass username anymore

        default:
            LoginPageView()
        }
    }
}

