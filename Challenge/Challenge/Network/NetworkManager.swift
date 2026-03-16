//
//  NetworkManager.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/11/26.
//
import Foundation
import RxSwift

enum NetworkError: Error {
    case invalidURL
    case dataFetchFail
    case decodingFail
}

// fetch 호출 - Single 생성 - URLSession 요청(JSON 디코딩) - Single.success/failure - subscribe로 전달
final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetch<T: Decodable>(endpoint: ITunesEndpoint) -> Single<T> {
        let session = URLSession(configuration: .default)
        
        return Single.create { observe in
            guard let url = endpoint.url else {
                observe(.failure(NetworkError.invalidURL))
                return Disposables.create()
            }
            
            session.dataTask(with: URLRequest(url: url)) { data, response, error in
                if let error = error {
                    observe(.failure(error))
                    return
                }
                
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode) else {
                    observe(.failure(NetworkError.dataFetchFail))
                    return
                }
                
                do {
                    let decodeData = try JSONDecoder().decode(T.self, from: data)
                    observe(.success(decodeData))
                } catch {
                    observe(.failure(NetworkError.decodingFail))
                }
            }.resume()
            
            return Disposables.create()
        }
    }
}
