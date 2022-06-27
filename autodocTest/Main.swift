//
//  Main.swift
//  autodocTest
//
//  Created by Dmitry Martynov on 24.06.2022.
//

import SwiftUI

@main
struct autodocTestApp: App {
    
    enum Start {
        case realServerAPI
        case mockModel
        case mockViewModel
    }
    
    let baseUrlApi = "https://webapi.autodoc.ru"
    let choice: Start = .realServerAPI
    
    var body: some Scene {
        WindowGroup {
         
            switch choice {
            case .realServerAPI:
                
                NewsView(viewModel: .init(
                             model: .init(
                                serverAgent: ServerAgent(
                                    baseURL: baseUrlApi))))
            case .mockModel:
                
                NewsView(viewModel: .init(model: .modelMock))
                
            case .mockViewModel:
                
                NewsView(viewModel: .newsViewModelMock)
            }
        }
    }
}
