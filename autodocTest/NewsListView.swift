//
//  NewsListView.swift
//  autodocTest
//
//  Created by Dmitry Martynov on 24.06.2022.
//

import SwiftUI
import Combine

//MARK: NewsListView

struct NewsView: View {
    
    @ObservedObject
    var viewModel: NewsViewModel
    
    var body: some View {
        
        List(viewModel.items) { item in
        
            LazyVStack{
                
                switch item {
                case let .news(newsVM):
                    NewsItemView(vm: newsVM)
                        .onAppear { viewModel.viewSignal.send(item) }
                
                case let .placeholder(placeholderVM):
                    PlaceholderView(vm: placeholderVM)
                }
            }
            .overlay(alignment: .topTrailing) {
                Text(String(item.id))
                    .foregroundColor(.primary.opacity(0.4))
            }
            
        }.listStyle(.plain)
    }
}

//MARK: NewsItemView

struct NewsItemView: View {
   
    var vm: NewsViewModel.NewsItem
    
    var body: some View {
        
        Button(action: vm.action) {
            VStack {
                Text(vm.title).font(.title3)
                
                if let imgUrl = vm.imageUrl  {
                
                if let image = vm.image {
                    image
                        .resizable()
                        .scaledToFit()
                        //.cornerRadius(10)
                        
                } else {
                    
                    //change for add cache
                    AsyncImage(url: URL(string: imgUrl)) { state in
                        switch state {

                        case .empty:
                            ImagePlaceholderView()
                                .overlay {
                                    Image("logo-min")
                                        .resizable()
                                        .scaledToFit()
                                        .scaleEffect(0.23)
                                        .opacity(0.7)
                                }
                 
                        case let .success(image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(10)
                                .onAppear { vm.image = image }
                 
                        case let .failure(error):
                            ImagePlaceholderView()
                                .overlay {
                                    Text(error.localizedDescription)
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                }
            }
        }
        .padding(.vertical)
    }
}

//MARK: PlaceholderItemView

struct PlaceholderView: View {
    
    let vm: NewsViewModel.PlaceholderItem
    var body: some View {
     
        VStack {
            
            Text(String(repeating: " ", count: 170))
                .font(.title3)
                //.background(Color.primary.opacity(0.08).cornerRadius(10))
            
            ImagePlaceholderView().padding(.vertical)
                
        }
        .padding(.vertical)
    }
}

//MARK: ImagePlaceholderView

struct ImagePlaceholderView: View {
    
    @State private var animateGradient = false
    
    var body: some View {
        
        LinearGradient(colors: [.primary.opacity(0.16),
                                .primary.opacity(0.1),
                                .primary.opacity(0.1)],
                       startPoint: animateGradient ? .trailing : .leading,
                       endPoint: animateGradient ? .leading : .leading)
        .cornerRadius(10)
        .animation(.easeOut(duration: 1.6).repeatForever(autoreverses: false),
                    value: animateGradient)
        .aspectRatio(16 / 10.67, contentMode: .fit)
        .onAppear { animateGradient = true }
                
    }
}

//@State private var isLoadingImage = false
//                    ImagePlaceholderView()
//                        .overlay {
//                            Image("logo-min")
//                                .resizable()
//                                .scaledToFit()
//                                .scaleEffect(0.23)
//                                .opacity(isLoadingImage ? 0 : 0.7 )
//                                .animation(.easeIn(duration: 1.8)
//                                                .repeatForever(autoreverses: true),
//                                                value: isLoadingImage)
//                        }
//                        .onAppear { isLoadingImage.toggle() }


//MARK: Canvas Previews

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView(viewModel: .newsViewModelMock)
            .previewInterfaceOrientation(.portrait)
    }
}
