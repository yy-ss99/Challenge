//
//  SearchSection.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/18/26.
//
import Foundation

enum SearchSection: Int, CaseIterable {
    case songs
    case albums
    case podcasts
    
    var title: String {
        switch self {
        case .songs:
            return "🔎 곡 검색결과"
        case .albums:
            return "🔎 앨범 검색결과"
        case .podcasts:
            return "🔎 팟캐스트 검색결과"
        }
    }
}
