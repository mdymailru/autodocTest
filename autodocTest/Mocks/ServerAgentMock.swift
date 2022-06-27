//
//  ServerAgentMock.swift
//  autodocTest
//
//  Created by Dmitry Martynov on 25.06.2022.
//

import Foundation

class ServerAgentMock: ServerAgentProtocol {
    
    let baseURL: String = ""
    
    private let bundle = Bundle(for: ServerAgentMock.self)
    private let decoder = JSONDecoder()
    
    func execute<Command: ServerCommand>
            (command: Command,
             completion: @escaping (Result<Command.Response, AgentError>) -> Void) {
                
        DispatchQueue.global()
            .asyncAfter(deadline: .now() + .milliseconds(4800)) {
            
            switch command {
            case let payload as ServerCommands.FetchNews:
                
                guard payload.page == 1
                else {
                    completion(.failure(.emptyData))
                    return
                }
                
                do {
                    let url = self.bundle.url(forResource: "AutodocResponseMock",
                                              withExtension: "json")!
                    let json = try Data(contentsOf: url)
                    let result = try self.decoder.decode(Command.Response.self, from: json)
                    
                    completion(.success(result))
                    
                } catch {
                    
                    completion(.failure(.failDecodeData(error)))
                }

            default:
                completion(.failure(.unknownResponse))
            }
        }
    }
}
