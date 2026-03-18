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

extension MusicItem {
   static let mockSongs: [MusicItem] = [
       MusicItem(
           collectionId: 1001,
           trackId: 2001,
           artistName: "아이유",
           collectionName: "Love wins all - Single",
           trackName: "Love wins all",
           artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/11/22/33/sample1.jpg/100x100bb.jpg",
           primaryGenreName: "K-Pop",
           releaseDate: "2024-01-24T12:00:00Z",
           country: "KOR",
           previewUrl: nil
       ),
       MusicItem(
           collectionId: 1002,
           trackId: 2002,
           artistName: "NewJeans",
           collectionName: "Get Up",
           trackName: "Super Shy",
           artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/22/33/44/sample2.jpg/100x100bb.jpg",
           primaryGenreName: "K-Pop",
           releaseDate: "2023-07-21T12:00:00Z",
           country: "KOR",
           previewUrl: nil
       ),
       MusicItem(
           collectionId: 1003,
           trackId: 2003,
           artistName: "태연",
           collectionName: "To. X - The 5th Mini Album",
           trackName: "To. X",
           artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/33/44/55/sample3.jpg/100x100bb.jpg",
           primaryGenreName: "K-Pop",
           releaseDate: "2023-11-27T12:00:00Z",
           country: "KOR",
           previewUrl: nil
       )
   ]
   
   static let mockAlbums: [MusicItem] = [
       MusicItem(
           collectionId: 3001,
           trackId: nil,
           artistName: "AKMU",
           collectionName: "항해",
           trackName: nil,
           artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/44/55/66/sample4.jpg/100x100bb.jpg",
           primaryGenreName: "K-Pop",
           releaseDate: "2019-09-25T12:00:00Z",
           country: "KOR",
           previewUrl: nil
       ),
       MusicItem(
           collectionId: 3002,
           trackId: nil,
           artistName: "DEAN",
           collectionName: "130 mood : TRBL",
           trackName: nil,
           artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/55/66/77/sample5.jpg/100x100bb.jpg",
           primaryGenreName: "R&B/Soul",
           releaseDate: "2016-03-24T12:00:00Z",
           country: "KOR",
           previewUrl: nil
       ),
       MusicItem(
           collectionId: 3003,
           trackId: nil,
           artistName: "아이유",
           collectionName: "Palette",
           trackName: nil,
           artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/66/77/88/sample6.jpg/100x100bb.jpg",
           primaryGenreName: "K-Pop",
           releaseDate: "2017-04-21T12:00:00Z",
           country: "KOR",
           previewUrl: nil
       )
   ]
   
   static let mockPodcasts: [MusicItem] = [
       MusicItem(
           collectionId: 4001,
           trackId: 5001,
           artistName: "OpenAI Podcast",
           collectionName: "AI Talk",
           trackName: "Swift와 AI",
           artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/77/88/99/sample7.jpg/100x100bb.jpg",
           primaryGenreName: "Technology",
           releaseDate: "2025-03-01T12:00:00Z",
           country: "KOR",
           previewUrl: nil
       ),
       MusicItem(
           collectionId: 4002,
           trackId: 5002,
           artistName: "iOS Dev Radio",
           collectionName: "앱개발 한입",
           trackName: "RxSwift 입문",
           artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/88/99/11/sample8.jpg/100x100bb.jpg",
           primaryGenreName: "Technology",
           releaseDate: "2025-02-10T12:00:00Z",
           country: "KOR",
           previewUrl: nil
       ),
       MusicItem(
           collectionId: 4003,
           trackId: 5003,
           artistName: "Design Cast",
           collectionName: "생각정리",
           trackName: "좋은 UI란?",
           artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/99/11/22/sample9.jpg/100x100bb.jpg",
           primaryGenreName: "Design",
           releaseDate: "2025-01-05T12:00:00Z",
           country: "KOR",
           previewUrl: nil
       )
   ]
}
