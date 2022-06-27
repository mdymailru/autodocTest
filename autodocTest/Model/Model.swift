//
//  Model.swift
//  autodocTest
//
//  Created by Dmitry Martynov on 24.06.2022.
//

import Foundation
import Combine
import SwiftUI

class Model {
    typealias NewsPage = (page: Int, newsPageData: [NewsItemData])
    
    let signal: PassthroughSubject<Signal, Never>
    
    private (set) var news: CurrentValueSubject<NewsPage, Never>
    
    private let serverAgent: ServerAgentProtocol
    
    var totalCount: Int
    let countOnPage = 15
    
    private var bindings: Set<AnyCancellable>
    private let queue = DispatchQueue(label: "ru.enta.model",
                                      qos: .userInitiated,
                                      attributes: .concurrent)
    
    init(serverAgent: ServerAgentProtocol) {
        
        self.serverAgent = serverAgent
        self.signal = .init()
        self.news = .init((page: 0, newsPageData: []))
        self.bindings = []
        self.totalCount = self.countOnPage
        
        bind()
    }
    
    private func bind() {
        
        signal
            .receive(on: queue)
            .sink { [unowned self] signal in
                
                switch signal {
                    
                case let payload as Signals.FetchNextNews:
                        
                    let requestPage = payload.page
                    let command = ServerCommands
                                    .FetchNews(page: requestPage,
                                                     countOnPage: countOnPage)
                        
                    
                    serverAgent.execute(command: command) { [unowned self] result in
                        
                        switch result {
                        case let .success(response):
                            
                            self.totalCount = response.totalCount
                            self.news.send((page: requestPage, newsPageData: response.news))

                        case let .failure(error):
                            print("fetching next News page error: \(error.localizedDescription)")
                            print(error.self)
                        }
                    }
                    
                    
                default: break
                }
            }
            .store(in: &bindings)
        
    }
}

extension Model {
    static var modelMock: Model { .init(serverAgent: ServerAgentMock()) }
}

//MARK: - Models Signals

protocol Signal {}

extension Model {
    
    enum Signals {
        
        struct FetchNextNews: Signal {
            let page: Int
        }
        
        enum NewsDetails {
            
            struct Request: Signal {
                let newsItem: NewsItemData
            }
            
            struct Complete: Signal  {
                let newsId: NewsItemData.ID
                let image: Image
            }
            
            struct Failed: Signal {
                let newsId: NewsItemData.ID
                let error: Error
            }
        }
    }
}
