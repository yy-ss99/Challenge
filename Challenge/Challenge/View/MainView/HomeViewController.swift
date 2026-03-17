//
//  HomeViewController.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/11/26.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

//UISearchBar 추가
//검색 시작 시 SearchResultViewController를 push 한다
//나중에 RxSwift로 검색어를 VM에 넘긴다

final class HomeViewController: UIViewController {
    private let homeView = HomeView()
    private let disposeBag = DisposeBag()
    private let searchBar = UISearchBar()
    
    private let viewModel = HomeViewModel()
    
    private var sections: [HomeSectionModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Music"
        
        homeView.collectionView.delegate = self
        homeView.collectionView.dataSource = self
        searchBar.delegate = self
        
        configure()
        bindViewModel()
        sendCurrentPageForPageControl()
    }
    
    func bindViewModel() {
        // just로 Void를 한번만 방출해서 뷰가 로드됨을 알림
        let input = HomeViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        
        // 아웃풋 만들기
        let output = viewModel.transform(input: input)
        
        //섹션데이터를 바인딩 해줌 - 각 섹션에 맞게 넘김
        output.sections
            .drive(with: self) { homeVC, sections in
                homeVC.sections = sections
                homeVC.homeView.collectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        // 로딩 상태변경 받음
        output.isLoading
            .drive(with: self) { homeVC, isLoading in
                if isLoading {
                    homeVC.homeView.showLoading()
                } else {
                    homeVC.homeView.hideLoading()
                }
            }
            .disposed(by: disposeBag)
        
        //에러 메세지 처리 - Signal은 보통 emit으로 구독
        output.errorMessage
            .emit(with: self) { owner, message in
                let alert = UIAlertController(
                    title: "에러",
                    message: message,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                owner.present(alert, animated: true)
            }.disposed(by: disposeBag)
    }
    
    func configure() {
        view.addSubview(homeView)
        view.addSubview(searchBar)
        searchBar.placeholder = "영화,팟캐스트 검색"
        searchBar.searchBarStyle = .minimal
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        homeView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }
    
    func sendCurrentPageForPageControl() {
        homeView.changeToCurrentPage = { [weak self] section, page in
            guard let self else { return }
            
            let indexPath = IndexPath(item: 0, section: section)
            
            if let footer = self.homeView.collectionView.supplementaryView(
                forElementKind: PageControlView.kind,
                at: indexPath
            ) as? PageControlView {
                footer.pageControl.currentPage = page
            }
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // 다음 화면 push 해주기
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let section = sections[indexPath.section]
        let item = section.items[indexPath.item]
        
        switch section.type {
        case .featuredAlbum:
            let cell: AlbumCardCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: item)
            return cell
            
        case .yhSongs, .tySongs:
            let cell: SongListCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: item)
            return cell
            
        case .lofiAlbums, .happyPopAlbums:
            let cell: AlbumCoverCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: item)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header: HomeSectionHeaderView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                for: indexPath
            )
            
            if let section = HomeSection(rawValue: indexPath.section) {
                header.titleLabel.text = section.title
            }
            
            return header
        }
        
        if kind == PageControlView.kind {
            let footer: PageControlView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                for: indexPath
            )
                    
            footer.pageControl.numberOfPages = 3
            footer.pageControl.currentPage = 0
            return footer
        }
        
        return UICollectionReusableView()
    }
}
// 오류 처리 extension으로 따로 처리
extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: String(describing: T.self),
            for: indexPath
        ) as? T else {
            fatalError("❌❌❌ \(T.self) cell dequeue 실패")
        }
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        ofKind kind: String,
        for indexPath: IndexPath
    ) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: T.identifier,
            for: indexPath
        ) as? T else {
            fatalError("❌❌❌ \(T.self) supplementary view dequeue 실패")
        }
        return view
    }
}
// 셀 identifier를 클래스 이름으로 자동화(셀은 리유저블 뷰를 상속받아서 따로 해줄필요없음)
extension UICollectionReusableView {
    static var identifier: String {
        String(describing: self)
    }
}
