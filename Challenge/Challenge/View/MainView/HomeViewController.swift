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
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlbumCardCell.identifier,
                for: indexPath
            ) as? AlbumCardCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: item)
            return cell
            
        case .yhSongs, .tySongs:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SongListCell.identifier,
                for: indexPath
            ) as? SongListCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: item)
            return cell
            
        case .lofiAlbums, .happyPopAlbums:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlbumCoverCell.identifier,
                for: indexPath
            ) as? AlbumCoverCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: item)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HomeSectionHeaderView.identifier,
                for: indexPath
            ) as? HomeSectionHeaderView else {
                return UICollectionReusableView()
            }
            
            if let section = HomeSection(rawValue: indexPath.section) {
                header.titleLabel.text = section.title
            }
            
            return header
        }
        
        if kind == PageControlView.kind {
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: PageControlView.identifier,
                for: indexPath
            ) as? PageControlView else {
                return UICollectionReusableView()
            }
            
            footer.pageControl.numberOfPages = 3
            footer.pageControl.currentPage = 0
            return footer
        }
        
        return UICollectionReusableView()
    }
}
