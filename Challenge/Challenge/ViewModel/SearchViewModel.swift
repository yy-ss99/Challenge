//
//  SearchViewModel.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/17/26.
//
import Foundation
import RxSwift
import RxCocoa

// 섹션에 넘기기 위한 타입
struct SearchSectionModel {
    let section: SearchSection
    let items: [SearchItem]
}

// 데이터 소스 구성을 위한 타입
nonisolated
enum SearchItem: Hashable, Sendable {
    case song(MusicItem)
    case album(MusicItem)
    case podcast(MusicItem)
}

final class SearchViewModel {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager()) {
        self.networkService = networkService
    }
    
    // 사용자한테 쿼리(검색어) 입력받음
    struct Input {
        let queryText: Observable<String>
    }
    
    // 컬렉션뷰에 줄 데이터, 검색중인지에 대한 정보, 에러메세지
    struct Output {
        let sections: Driver<[SearchSectionModel]>
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
    }
    
    func transform(input: Input) -> Output {
        // 상태
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        // 이벤트
        let errorRelay = PublishRelay<String>()
        
        let sections = input.queryText
        // 검색 속도에서 매번 보내는건 비효율 적이라 조금 멈출때 보냄 - UI 이벤트니까 메인에서
            .debounce(.milliseconds(400), scheduler: MainScheduler.instance)
        // 서치뷰에서 가져올 경우를 위해 공백 없애줌
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        // 직전 값이랑 같으면 무시해라
            .distinctUntilChanged()
        // query 받은거 중에 가장 최신것만 유효하게 유지하도록 설정한건데 어떻게 하냐면
            .flatMapLatest { [weak self] query -> Observable<[SearchSectionModel]> in
                guard let self else { return .just([]) }
                
                // 아무것도 안들어왔으면 그냥 빈값 뱉음
                if query.isEmpty {
                    return .just([])
                }
                
                // 로딩되고 있으니 값 변경하기
                loadingRelay.accept(true)
                
                // 쿼리를 담은 다음에 API 요청함 가져옴
                return self.fetchSearchData(query: query)
                // Single로 받아오기 때문에 Observable로 바꿈
                    .asObservable()
                //로딩은 사이드이펙트 이니까 do 사용 - 결과 나오면 로딩 끝이니까 값 바꿔줌
                    .do(onNext: { _ in
                        loadingRelay.accept(false)
                    })
                // 오류 잡기
                    .catch { error in
                        loadingRelay.accept(false)
                        let message = self.makeErrorMessage(from: error)
                        errorRelay.accept(message)
                        return .just([])
                    }
            }
            .asDriver(onErrorJustReturn: []) // 드라이브는 UI 전용이라 오류 배출 안돼서 넣어줌
        
        return Output(
            sections: sections,
            isLoading: loadingRelay.asDriver(),
            errorMessage: errorRelay.asSignal()
        )
    }
    
    func fetchSearchData(query: String) -> Single<[SearchSectionModel]> {
        let songsResponse: Single<ITunesResponse<MusicItem>> = networkService.fetch(endpoint: .searchSongs(term: query))
        let albumsResponse: Single<ITunesResponse<MusicItem>> = networkService.fetch(endpoint: .searchAlbums(term: query))
        let podcastsResponse: Single<ITunesResponse<MusicItem>> = networkService.fetch(endpoint: .searchPodcasts(term: query))
        
        // 동시에 묶어서 보냄
        return Single.zip(songsResponse, albumsResponse, podcastsResponse) { songs, albums, podcasts in
            // 이렇게 묶어서 여기 담아서 UI에 넘겨줌 
            var sections: [SearchSectionModel] = []
            
            // 다 다른 섹션에 들어가야해서 종류별로 나누어서 담아줌
            let songItems = songs.results.map { SearchItem.song($0) }
            let albumItems = albums.results.map { SearchItem.album($0) }
            let podcastItems = podcasts.results.map { SearchItem.podcast($0) }
            
            // 데이터 없는데 섹션만 있는걸 방지하기 위해서
            if !songItems.isEmpty {
                sections.append(
                    SearchSectionModel(
                        section: .songs,
                        items: songItems
                    )
                )
            }
            
            if !albumItems.isEmpty {
                sections.append(
                    SearchSectionModel(
                        section: .albums,
                        items: albumItems
                    )
                )
            }
            
            if !podcastItems.isEmpty {
                sections.append(
                    SearchSectionModel(
                        section: .podcasts,
                        items: podcastItems
                    )
                )
            }
            
            return sections
        }
    }
    
    private func makeErrorMessage(from error: Error) -> String {
        if let networkError = error as? NetworkError {
            return networkError.localizedDescription
        } else {
            return error.localizedDescription
        }
    }
}

