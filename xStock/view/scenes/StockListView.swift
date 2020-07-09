//
//  StockListView.swift
//  xStock
//
//  Created by Terrance Lam on 30/6/2020.
//  Copyright © 2020 terbb. All rights reserved.
//

import SwiftUI

struct StockListView: View{
    @ObservedObject var observable = StockListObserver()
    @State private var bottomSheetShown = false

    init() {
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundColor = UIColor.App.dark
    }
    
    var body: some View{
        ZStack{
            Color(UIColor.App.dark).edgesIgnoringSafeArea(.all)
            NavigationView{
                
                GeometryReader { geometry in
                    StockTableView(data: self.observable.stockList)
                    BottomSheetView(isOpen: self.$bottomSheetShown, maxHeight: geometry.size.height * 0.7) {
                        Color.clear
                    }
                }
                .navigationBarTitle("Stocks: \(observable.count)", displayMode: .automatic)
                .navigationBarItems(trailing: Button(action: getList, label: {
                    Text("Reload").foregroundColor(Color(UIColor.App.light))
                }))

            }.clipped()
        }
    }
    
    func getList(){
        observable.getStockList()
    }
}

struct StockTableView: View{
    var data: [StockHeader]?
    var body: some View{
        List(data ?? []){ entity in
            NavigationLink(destination: StockDetailView(stockHeader: entity)){
                StockRow(stock: entity)
            }
        }
        .background(Color(UIColor.App.dark))
        .environment(\.defaultMinListRowHeight, 30)
    }
}

struct StockRow: View{
    var stock: StockHeader
    var body: some View{
        HStack{
            Text(stock.name)
                .padding(8)
                .font(.caption)
                .foregroundColor(.white)
            Spacer()
        }
    }
}

let BottomSheetMinHeightRatio: CGFloat = 0.2
struct BottomSheetView<Content: View> : View {
    @GestureState private var translation: CGFloat = 0
    @Binding var isOpen: Bool
    
    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content
    
    init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content ) {
        self.maxHeight = maxHeight
        self.minHeight = maxHeight * BottomSheetMinHeightRatio
        self._isOpen = isOpen
        self.content = content()
    }
    
    private var offset: CGFloat{
        isOpen ? 0 : maxHeight - minHeight
    }
    
    private var indicator: some View{
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.gray)
            .frame(
                width: 100,
                height: 4
        )
    }
    
    var body: some View{
        GeometryReader { geometry in
            VStack(spacing: 0) {
                self.indicator.padding()
                self.content
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(VisualEffectView.init(effect: .some(UIBlurEffect(style: .dark))))
            .cornerRadius(5)
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.interactiveSpring())
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = self.maxHeight * 0.4//snapRatio
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    self.isOpen = value.translation.height < 0
                }
            )
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

// MARK: - Preview
let fakeStock = StockHeader(id: "1123", name: "Stock That is fake", shortName: "STF", country: "HK")
struct StockListView_Previews: PreviewProvider {
    static var previews: some View {
        StockListView()
//        StockRow(stock: fakeStock)
    }
}
