//
//  ContentView.swift
//  storekit-subscribe-unit
//
//  Created by John Xu on 1/18/26.
//

import SwiftUI

struct ContentView: View {
    @State var storeVM = StoreViewModel()
    
    
    var body: some View {
        VStack {
            if storeVM.purchasedSubscriptions.isEmpty {
                SubscriptionView2()
            } else {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Premium App")
            }
        }
        .padding()
        .environment(storeVM)
    }
}

#Preview {
    ContentView()
}
