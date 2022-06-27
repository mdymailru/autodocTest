//
//  ServerAgent.swift
//  autodocTest
//
//  Created by Dmitry Martynov on 25.06.2022.
//

import Foundation

protocol ServerAgentProtocol {
    
    var baseURL: String { get }
    
    func execute<Command: ServerCommand>
            (command: Command,
             completion: @escaping (Result<Command.Response, AgentError>) -> Void)
}

class ServerAgent: ServerAgentProtocol {
    
    let baseURL: String
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    init(baseURL: String) {
        
        self.baseURL = baseURL
    }
    
    func execute<Command: ServerCommand>
            (command: Command,
             completion: @escaping (Result<Command.Response, AgentError>) -> Void) {
        
        guard let request = request(from: command)
        else {
            completion(.failure(.badRequest))
            return
        }
         
        session.dataTask(with: request) { [unowned self] data, response, error in
                
            if let error = error {
                completion(.failure(.sessionError(error)))
                return
            }
                
            guard let data = data
            else {
                completion(.failure(.emptyData))
                return
            }
                
            do {
                
                let response = try decoder.decode(Command.Response.self, from: data)
                completion(.success(response))
                    
            } catch {
                    
                completion(.failure(.failDecodeData(error)))
            }
                
        }.resume()
        
    }
    
    private func request<Command>(from command: Command) -> URLRequest?
                        where Command : ServerCommand {
        
        guard let url = URL(string: baseURL + command.endpoint + command.parameters)
        else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = command.method.rawValue
        print("Fetch URL: \(url.description)")
                            
        return request
    }
}

protocol ServerResponse: Decodable {
    
    var news: [NewsItemData] { get } 
    var totalCount: Int { get }
}

enum AgentError: Error {
    
    case badRequest
    case sessionError(Error)
    case unknownResponse
    case emptyData
    case failDecodeData(Error)
}

protocol ServerCommand {
    
    associatedtype Response: ServerResponse

    var endpoint: String { get }
    var method: ServerCommandMethod { get }
    var parameters: String { get }
}

enum ServerCommandMethod: String {
    
    case post = "POST"
    case get = "GET"
}
