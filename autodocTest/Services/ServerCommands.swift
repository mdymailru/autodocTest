//
//  ServerCommands.swift
//  autodocTest
//
//  Created by Dmitry Martynov on 25.06.2022.
//

import Foundation

enum ServerCommands {

    struct FetchNews: ServerCommand {
        
        typealias Response = FetchNews.Responses
        
        let page: Int
        let countOnPage: Int
        
        let endpoint = "/api/news"
        let method: ServerCommandMethod = .get
        let parameters: String
        
        init(page: Int, countOnPage: Int) {
            
            self.page = page
            self.countOnPage = countOnPage
            self.parameters = "/\(page)/\(countOnPage)"
        }
        
        struct Responses: ServerResponse {
            
            var news: [NewsItemData]
            var totalCount: Int
            
        }
    }
}
