//
//  NetworkManager.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/11/26.
//
import Foundation
import RxSwift

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case dataFetchFail
    case decodingFail
    case requestFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL 입니다."
        case .dataFetchFail:
            return "데이터를 불러오지 못했습니다."
        case .decodingFail:
            return "데이터를  디코딩하지 못했습니다."
        case .requestFailed:
            return "데이터 요청 실패했습니다."
        }
    }
}

// fetch 호출 - Single 생성 - URLSession 요청(JSON 디코딩) - Single.success/failure - subscribe로 전달
final class NetworkManager: NetworkService {
    private let session: URLSession
    
    // 세션 넣어서 테스트 가능하게 변경
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(endpoint: ITunesEndpoint) -> Single<T> {
        return Single.create { observe in
            guard let url = endpoint.url else {
                observe(.failure(NetworkError.invalidURL))
                return Disposables.create()
            }
            
            self.session.dataTask(with: URLRequest(url: url)) { data, response, error in
                if let error = error {
                    observe(.failure(NetworkError.requestFailed(error)))
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
