//
//  DetailViewModel.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/19/26.
//
import Foundation
import RxSwift
import RxCocoa

// 어떤거 띄워줄지 케이스 나누어줌
enum DetailContentType {
    case song
    case album
    case podcast
}

// 미디어 그리는데 필요한 정보 모음
struct DetailMedia {
    let mediaURL: URL?
    let showsVideo: Bool
    let showsGuideText: Bool
    let statusText: String
}

struct MatchedMusicVideo {
    let title: String?
    let previewURL: URL?
}

final class DetailViewModel: ViewModelType {
    private let musicItem: MusicItem
    private let contentType: DetailContentType
    private let networkService: NetworkService
    
    // 디테일뷰에 필요한거 가져옴
    init(
        item: MusicItem,
        contentType: DetailContentType,
        networkService: NetworkService = NetworkManager()
    ) {
        self.musicItem = item
        self.contentType = contentType
        self.networkService = networkService
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let title: Driver<String>
        let subtitle: Driver<String>
        let artworkURL: Driver<URL?>
        let media: Driver<DetailMedia>
        let genreText: Driver<String>
        let releaseDateText: Driver<String>
        let countryText: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        // item을 구독할 수 있게 스트림으로 바꾸어줌
        let item = input.viewDidLoad
            .map { [musicItem] in musicItem }
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(
            title: item
                .map { $0.trackName ?? $0.collectionName ?? "제목 없음" },
            
            subtitle: item
                .map { item in
                    let artist = item.artistName ?? "아티스트 정보 없음"
                    let collection = item.collectionName ?? "앨범 정보 없음"
                    return "\(artist) • \(collection)"
                },
            
            artworkURL: item
                .map { musicItem in
                    musicItem.artworkUrl100
                        .map { $0.replacingOccurrences(of: "100x100", with: "500x500") }
                        .flatMap(URL.init(string:))
                },
            
            // 화면 뜨면 여기서 만들어서전달
            media: input.viewDidLoad
                .withUnretained(self)
                .flatMapLatest { `self`, _ -> Observable<DetailMedia> in
                    return self.makeMedia()
                        .asObservable()
                }
                .asDriver(onErrorJustReturn: DetailMedia(
                    mediaURL: nil,
                    showsVideo: false,
                    showsGuideText: false,
                    statusText: "이 항목은 자동 재생을 지원하지 않습니다."
                )),
            
            genreText: item
                .map { "장르: \($0.primaryGenreName ?? "정보 없음")" },
            
            releaseDateText: item
                .map { musicItem in
                    "발매일: \(self.formatReleaseDate(musicItem.releaseDate))"
                },
            
            countryText: item
                .map { "국가: \($0.country ?? "정보 없음")" }
        )
    }
    
    // TODO: 앨범 주소 가져오기
    
    private func makeMedia() -> Single<DetailMedia> {
        switch contentType {
        case .album:
            return fetchRelatedMusicVideo()
                .map { matchedVideo in
                    if let previewURL = matchedVideo.previewURL {
                        return DetailMedia(
                            mediaURL: previewURL,
                            showsVideo: true,
                            showsGuideText: true,
                            statusText: "\(matchedVideo.title ?? "관련 뮤직비디오") 자동 재생 중"
                        )
                    } else {
                        return DetailMedia(
                            mediaURL: nil,
                            showsVideo: false,
                            showsGuideText: false,
                            statusText: "관련 뮤직비디오가 없어서 썸네일 이미지를 보여줍니다."
                        )
                    }
                }
            
        case .song, .podcast:
            let previewURL = musicItem.previewUrl.flatMap(URL.init(string:))
            if previewURL != nil {
                return .just(
                    DetailMedia(
                        mediaURL: previewURL,
                        showsVideo: false,
                        showsGuideText: true,
                        statusText: "미리듣기 자동 재생 중"
                    )
                )
            } else {
                return .just(
                    DetailMedia(
                        mediaURL: nil,
                        showsVideo: false,
                        showsGuideText: false,
                        statusText: "이 항목은 자동 재생을 지원하지 않습니다."
                    )
                )
            }
        }
    }
    
    private func fetchRelatedMusicVideo() -> Single<MatchedMusicVideo> {
        let searchTerm = [musicItem.artistName, musicItem.collectionName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        guard !searchTerm.isEmpty else {
            return .just(MatchedMusicVideo(title: nil, previewURL: nil))
        }
        
        return searchMusicVideo(term: searchTerm)
            .catchAndReturn(MatchedMusicVideo(title: nil, previewURL: nil))
    }
    
    private func searchMusicVideo(term: String) -> Single<MatchedMusicVideo> {
        let response: Single<ITunesResponse<MusicItem>> = networkService.fetch(
            endpoint: .searchMusicVideos(term: term)
        )
        
        return response.map { [musicItem] response in
            let artistName = musicItem.artistName?.lowercased()
            
            let exactArtistMatch = response.results.first { musicVideo in
                guard let previewURL = musicVideo.previewUrl, !previewURL.isEmpty else {
                    return false
                }
                
                guard let artistName else { return true }
                return musicVideo.artistName?.lowercased() == artistName
            }
            
            if let exactArtistMatch {
                return MatchedMusicVideo(
                    title: exactArtistMatch.trackName ?? exactArtistMatch.collectionName,
                    previewURL: exactArtistMatch.previewUrl.flatMap(URL.init(string:))
                )
            }
            
            return MatchedMusicVideo(title: nil, previewURL: nil)
        }
    }
    
    private func formatReleaseDate(_ dateString: String?) -> String {
        guard let dateString else { return "정보 없음" }
        
        let inputFormatter = ISO8601DateFormatter()
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        outputFormatter.locale = Locale(identifier: "ko_KR")
        
        return outputFormatter.string(from: date)
    }
}
