//
//  DetailViewModel.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/19/26.
//
import Foundation
import RxSwift
import RxCocoa

final class DetailViewModel: ViewModelType {
    private let item: MusicItem
    
    init(item: MusicItem) {
        self.item = item
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let title: Driver<String>
        let subtitle: Driver<String>
        let artworkURL: Driver<URL?>
        let previewURL: Driver<URL?>
        let genreText: Driver<String>
        let releaseDateText: Driver<String>
        let countryText: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        // item을 구독할 수 있게 스트림으로 바꾸어줌
        // 구독할떄마다 불러오니까 쉐어함 - 근데 나중에 구독한 애들까지 다 볼 수 있게 replay
        let item = Observable.just(item)
            .share(replay: 1)
        
        return Output(
            title: item
                .map { $0.trackName ?? $0.collectionName ?? "제목 없음" }
                .asDriver(onErrorJustReturn: "제목 없음"),
            
            subtitle: item
                .map { item in
                    let artist = item.artistName ?? "아티스트 정보 없음"
                    let collection = item.collectionName ?? "앨범 정보 없음"
                    return "\(artist) • \(collection)"
                }
                .asDriver(onErrorJustReturn: "정보 없음"),
            
            artworkURL: item
                .map { musicItem in
                    musicItem.artworkUrl100
                        .map { $0.replacingOccurrences(of: "100x100", with: "500x500") }
                        .flatMap(URL.init(string:))
                }
                .asDriver(onErrorJustReturn: nil),
            
            previewURL: item
                .map { $0.previewUrl.flatMap(URL.init(string:)) }
                .asDriver(onErrorJustReturn: nil),
            
            genreText: item
                .map { "장르: \($0.primaryGenreName ?? "정보 없음")" }
                .asDriver(onErrorJustReturn: "장르: 정보 없음"),
            
            releaseDateText: item
                .map { [weak self] in
                    "발매일: \(self?.formatReleaseDate($0.releaseDate) ?? "정보 없음")"
                }
                .asDriver(onErrorJustReturn: "발매일: 정보 없음"),
            countryText: item
                .map { "국가: \($0.country ?? "정보 없음")" }
                .asDriver(onErrorJustReturn: "국가: 정보 없음")
        )
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
