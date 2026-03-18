//
//  HomeViewModel.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/12/26.
//
import Foundation
import RxSwift
import RxCocoa

// 한번에 가져와서 섹션별로 넣어주기 위해서 한번 담아줌
struct HomeSectionModel {
    let type: HomeSection
    let items: [MusicItem]
}

final class HomeViewModel: ViewModelType {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager()) {
        self.networkService = networkService
    }
    
    // 받아올 정보: viewDidLoad 됐는가
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    // 줘야 할 정보: 섹션 정보, 로딩중인지 아닌지 판별(스피너 보여주기), 에러일 경우 넘기기
    // 다 UI 관련임으로 Driver과 Signal 사용
    struct Output {
        let sections: Driver<[HomeSectionModel]>
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
    }
    
    func transform(input: Input) -> Output {
        // 로딩 상태는 현재 상태값에 가깝기 때문에 BehaviorRelay 사용 - 초기값은 화면 전에는 로딩중일 수 없기때문에 false
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        
        // 에러가 일어나는 건 이벤트에 가깝기 때문에(한번 발생) BehaviorRelay 사용
        let errorRelay = PublishRelay<String>()
        
        // sections UI를 그릴때 쓰기때문에 Driver타입으로 구현
        // isLoading 사이드 이펙트는 do로 구현(부수효과), relay는 onNext 대신 accept 사용
        let sections = input.viewDidLoad
            .do(onNext: { _ in
                loadingRelay.accept(true)
            })
        // 최신 요청만 적절하게 처리하기 위해서 flatMapLatest
            .flatMapLatest { [weak self] _ -> Observable<[HomeSectionModel]> in
                // 반환값으로 빈배열 가진 just로 하나 뱉음
                guard let self else { return .just([])}
                
                // fetchHomeSectionsData()는 Single<[HomeSectionModel]>를 반환 그래서 asObservable로 타입변환해줌
                return self.fetchHomeSectionsData()
                    .asObservable()
                    .do(onNext: { _ in
                        loadingRelay.accept(false) // 로딩 상태를 바꾸어줌
                    })
                    .catch { error in // 오류 잡기
                        loadingRelay.accept(false)
                        let message = self.makeErrorMessage(from: error)
                        errorRelay.accept(message)
                        return .just([])
                    }
            }
            .asDriver(onErrorJustReturn: [])
        // 성공시 나가는 반환타입은 Driver<[HomeSectionModel]>이기 떄문에 변환해줌
        // Driver는 오류는 못보내기 떄문에 여기서 오류시 어떤 값 내보낼지 정해야함)
        
        return Output(
            sections: sections,
            isLoading: loadingRelay.asDriver(), // Observable 이기떄문에 변환해줌
            errorMessage: errorRelay.asSignal() // Observable 이기떄문에 변환해줌
        )
    }
    
    // fetch해줌 다 같이 뜨는게 자연스럽기 때문에 zip 사용해서 HomeSectionModel에 넣어서 넘김
    func fetchHomeSectionsData() -> Single<[HomeSectionModel]> {
        let featuredAlbum: Single<ITunesResponse<MusicItem>> = networkService.fetch(endpoint: .kpopAlbums)
        let yhSongs: Single<ITunesResponse<MusicItem>> = networkService.fetch(endpoint: .yhSongs)
        let tySongs: Single<ITunesResponse<MusicItem>> = networkService.fetch(endpoint: .tySongs)
        let lofiAlbums: Single<ITunesResponse<MusicItem>> = networkService.fetch(endpoint: .lofiChillAlbums)
        let happyPopAlbums: Single<ITunesResponse<MusicItem>> = networkService.fetch(endpoint: .happyPopAlbums)
        
        return Single.zip(featuredAlbum, yhSongs, tySongs, lofiAlbums, happyPopAlbums){ featured, yhSongs, tySongs, lofi, happy in
            
            return [
                HomeSectionModel(
                    type: .featuredAlbum,
                    items: featured.results
                ),
                HomeSectionModel(
                    type: .yhSongs,
                    items: yhSongs.results
                ),
                HomeSectionModel(
                    type: .tySongs,
                    items: tySongs.results
                ),
                HomeSectionModel(
                    type: .lofiAlbums,
                    items: lofi.results
                ),
                HomeSectionModel(
                    type: .happyPopAlbums,
                    items: happy.results
                )
            ]
        }
    }
    
    // 오류메세지를 넘김
    private func makeErrorMessage(from error: Error) -> String {
        if let networkError = error as? NetworkError {
            return networkError.localizedDescription
        } else {
            return error.localizedDescription
        }
    }
}
