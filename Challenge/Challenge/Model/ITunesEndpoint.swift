//
//  ITunesEndpoint.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/12/26.
//
import Foundation

enum ITunesEndpoint {
    case kpopAlbums
    case popAlbums
    case yhSongs
    case tySongs
    case lofiChillAlbums
    case happyPopAlbums
    
    static let baseURL = "https://itunes.apple.com/search"
    
    var queryItems: [URLQueryItem] {
        switch self {
            // kpop 앨범 가져오기
        case .kpopAlbums:
            return [
                URLQueryItem(name: "term", value: "kpop"),
                URLQueryItem(name: "media", value: "music"),
                URLQueryItem(name: "entity", value: "album"),
                URLQueryItem(name: "limit", value: "10"),
                URLQueryItem(name: "country", value: "KR")
            ]
            // pop 앨범 가져오기
        case .popAlbums:
            return [
                URLQueryItem(name: "term", value: "pop"),
                URLQueryItem(name: "media", value: "music"),
                URLQueryItem(name: "entity", value: "album"),
                URLQueryItem(name: "limit", value: "10"),
                URLQueryItem(name: "country", value: "KR")
            ]
            // 윤하 노래 가져오기
        case .yhSongs:
            return [
                URLQueryItem(name: "term", value: "윤하"),
                URLQueryItem(name: "media", value: "music"),
                URLQueryItem(name: "entity", value: "song"),
                URLQueryItem(name: "limit", value: "9"),
                URLQueryItem(name: "country", value: "KR")
            ]
            // 태연 노래 가져오기
        case .tySongs:
            return [
                URLQueryItem(name: "term", value: "태연"),
                URLQueryItem(name: "media", value: "music"),
                URLQueryItem(name: "entity", value: "song"),
                URLQueryItem(name: "limit", value: "9"),
                URLQueryItem(name: "country", value: "KR")
            ]
            // 로파이 칠 노래 앨범(주제에 맞게)
        case .lofiChillAlbums:
            return [
                URLQueryItem(name: "term", value: "lofi chill"),
                URLQueryItem(name: "media", value: "music"),
                URLQueryItem(name: "entity", value: "album"),
                URLQueryItem(name: "limit", value: "10"),
                URLQueryItem(name: "country", value: "KR")
            ]
            // happyPop 앨범들 가져오기 
        case .happyPopAlbums:
            return [
                URLQueryItem(name: "term", value: "happy pop"),
                URLQueryItem(name: "media", value: "music"),
                URLQueryItem(name: "entity", value: "album"),
                URLQueryItem(name: "limit", value: "10"),
                URLQueryItem(name: "country", value: "KR")
            ]
        }
    }
    
    var url: URL? {
        var components = URLComponents(string: ITunesEndpoint.baseURL)
        components?.queryItems = queryItems
        return components?.url
    }
}
