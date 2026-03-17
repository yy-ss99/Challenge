//
//  HomeSection.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/16/26.
//
import Foundation

enum HomeSection: Int, CaseIterable {
    case featuredAlbum
    case yhSongs
    case tySongs
    case lofiAlbums
    case happyPopAlbums
    
    var title: String {
        switch self {
        case .featuredAlbum:
            return "#Kpop"
        case .yhSongs:
            return "인기 급상승 가수"
        case .tySongs:
            return "이 노래 어떠세요?"
        case .lofiAlbums:
            return "lofi Music"
        case .happyPopAlbums:
            return "Happy Pop"
        }
    }
}
