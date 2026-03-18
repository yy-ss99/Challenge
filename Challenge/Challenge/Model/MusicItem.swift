//
//  MusicItem.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/12/26.
//
import Foundation

nonisolated
struct MusicItem: Decodable, Hashable, Sendable {
    let collectionId: Int?
    let trackId: Int?
    
    let artistName: String?
    let collectionName: String?
    let trackName: String?
    
    let artworkUrl100: String?
    let primaryGenreName: String?
    let releaseDate: String?
    let country: String?
    
    let previewUrl: String?
}
