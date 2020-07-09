//
//  StockDetailView.swift
//  xStock
//
//  Created by Terrance Lam on 1/7/2020.
//  Copyright © 2020 terbb. All rights reserved.
//

import SwiftUI

struct StockDetailView: View {
    let stockHeader: StockHeader
    var body: some View{
        Color.red.edgesIgnoringSafeArea(.all)
            .navigationBarTitle(Text(stockHeader.name), displayMode: .inline)
    }
}

struct StockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StockDetailView(stockHeader: fakeStock)
    }
}
