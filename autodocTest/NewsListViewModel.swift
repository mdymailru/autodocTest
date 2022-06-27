//
//  NewsListViewModel.swift
//  autodocTest
//
//  Created by Dmitry Martynov on 26.06.2022.
//

import Foundation
import SwiftUI
import Combine

class NewsViewModel: ObservableObject {
    
    @Published
    var items: [ItemViewModel]
    let viewSignal: PassthroughSubject<ItemViewModel, Never> = .init()
    //let viewSignalImg: PassthroughSubject<Image,>
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    enum ItemViewModel: Identifiable {
        
        case news(NewsItem)
        case placeholder(PlaceholderItem)
        
        var id: Int {
            switch self {
            case let .news(viewModel):
                return viewModel.id
            case let .placeholder(viewModel):
                return viewModel.id
            }
        }
    }
    
    init(model: Model) {
        self.items = []
        self.model = model

        generatePlaceholder(forPage: 1)
        bind()
        
        model.signal.send(Model.Signals.FetchNextNews(page: 1))
    }
    
    private init(items: [ItemViewModel], model: Model ) {
        self.items = items
        self.model = model
    }
    
    private func bind() {
       
        model.news
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] pageNews in
                
                guard !pageNews.newsPageData.isEmpty else { return }
                let nextId = (pageNews.page - 1) * model.countOnPage
                
                for (index, item) in pageNews.newsPageData.enumerated() {

                    if case .news = items[nextId + index] {
                        //???
                    } else {
                        
                    withAnimation(Animation.linear(duration: 1.5)) {
                        self.items[nextId + index] = ItemViewModel
                                                        .news(.init(id: nextId + index,
                                                                    title: item.title,
                                                                    image: nil,
                                                                    imageUrl: item.titleImageUrl,
                                                                    page: pageNews.page,
                                                                    action: {}))
                        print("Fetched: \(nextId + index)")
                    }
                    }
                }
                
        }.store(in: &bindings)
        
//MARK: ViewSignal
        
        viewSignal
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] itemVM in
                
                if case let .news(newsVM) = itemVM,
                   (newsVM.id + 1) % model.countOnPage == 0   {
                
                    let nextPage = newsVM.page + 1
                    
                    generatePlaceholder(forPage: nextPage)
                    model.signal.send(Model.Signals.FetchNextNews(page: nextPage))
                    
                }
        }.store(in: &bindings)
    }
    
    private func generatePlaceholder(forPage: Int) {
        
        let nextId = (forPage - 1) * model.countOnPage
        let endId = nextId + model.countOnPage
        
        for id in nextId..<endId {
            print(model.totalCount)
            guard self.items.firstIndex(where: { $0.id == id }) == nil,
                  id < model.totalCount
            else { return }
            
            print("Placeholder added: id: \(id) Page: \(forPage)")
            
            withAnimation {
                self.items.append(ItemViewModel.placeholder(
                                    .init(id: id, page: forPage)))
            }
        }
        
    }
    
//MARK: Item ViewModels
    
    class NewsItem: Identifiable {
        var id: Int
        let title: String
        var image: Image?
        let imageUrl: String?
        let page: Int
        let action: () -> Void
        
        init(id: Int, title: String, image: Image?, imageUrl: String?, page: Int, action: @escaping () -> Void) {
            self.id = id
            self.title = title
            self.image = image
            self.imageUrl = imageUrl
            self.page = page
            self.action = action
        }
    }
    
    struct PlaceholderItem: Identifiable {
        let id: Int
        let page: Int
    }
}


//MARK: NewsViewModelMock

extension NewsViewModel {
    
    static var newsViewModelMock: NewsViewModel {
    
        let items: [ItemViewModel]  = [
            
            .news(.init(id: 0,
                        title: "Peugeot 408 Coupe 2023 для тех, кто устал от скучных семейных автомобилей",
                        image: Image("1"),
                        imageUrl: "",
                        page: 1,
                        action: {})),
            .news(.init(id: 1,
                        title: "Салон Honda CR-V 2023 будет напоминать интерьер Civic",
                        image: Image("2"),
                        imageUrl: "",
                        page: 1,
                        action: {})),
            .news(.init(id: 2,
                        title: "Volkswagen ID. AERO — предвестник электрического седана среднего размера",
                        image: Image("3"),
                        imageUrl: "",
                        page: 1,
                        action: {})),
            .news(.init(id: 3,
                        title: "График работы с 1 по 10 мая",
                        image: nil,
                        imageUrl: "",
                        page: 1,
                        action: {})),
            .placeholder(.init(id: 4, page: 2)),
            .placeholder(.init(id: 5, page: 2))
            
        ]
        
        return .init(items: items, model: .modelMock)
    }
}


