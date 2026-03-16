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


struct HomeSectionModel {
    let type: HomeSection
    let items: [MusicItem]
}

final class HomeViewController: UIViewController {
    
    private let homeView = HomeView()
    private let disposeBag = DisposeBag()
    
    private var sections: [HomeSectionModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Music"
        
        homeView.collectionView.delegate = self
        homeView.collectionView.dataSource = self
        
        configure()
        makeDummyData()
    }
    
    func bindViewModel() {
        // 뷰모델이 흘리는 정보 구독하기
        
    }
    
    func configure() {
        view.addSubview(homeView)
        
        homeView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let section = sections[indexPath.section]
        let item = section.items[indexPath.item]
        
        switch section.type {
        case .featuredAlbum:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlbumCardCell.identifier,
                for: indexPath
            ) as! AlbumCardCell
            cell.configure(with: item)
            return cell
            
        case .popularSongs, .recommendedSongs:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SongListCell.identifier,
                for: indexPath
            ) as! SongListCell
            cell.configure(with: item)
            return cell
            
        case .popularAlbums, .newAlbums:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlbumCoverCell.identifier,
                for: indexPath
            ) as! AlbumCoverCell
            cell.configure(with: item)
            return cell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HomeSectionHeaderView.identifier,
            for: indexPath
        ) as! HomeSectionHeaderView
        
        header.titleLabel.text = sections[indexPath.section].type.title
        return header
    }
    
    private func makeDummyData() {
        
        sections = [
            HomeSectionModel(
                type: .featuredAlbum,
                items: MusicItem.dummy
            ),
            
            HomeSectionModel(
                type: .popularSongs,
                items: MusicItem.dummy
            ),
            
            HomeSectionModel(
                type: .recommendedSongs,
                items: MusicItem.dummy
            ),
            
            HomeSectionModel(
                type: .popularAlbums,
                items: MusicItem.dummy
            ),
            
            HomeSectionModel(
                type: .newAlbums,
                items: MusicItem.dummy
            )
        ]
        
        homeView.collectionView.reloadData()
    }
}


extension MusicItem {
    
    static let dummy: [MusicItem] = [
        MusicItem(
            collectionId: 1,
            trackId: 101,
            artistName: "아이유",
            collectionName: "Palette",
            trackName: "밤편지",
            artworkUrl100: nil,
            primaryGenreName: "K-Pop",
            releaseDate: "2017-04-21",
            country: "KR",
            previewUrl: nil
        ),
        
        MusicItem(
            collectionId: 2,
            trackId: 102,
            artistName: "NewJeans",
            collectionName: "Get Up",
            trackName: "Super Shy",
            artworkUrl100: nil,
            primaryGenreName: "K-Pop",
            releaseDate: "2023-07-21",
            country: "KR",
            previewUrl: nil
        ),
        
        MusicItem(
            collectionId: 3,
            trackId: 103,
            artistName: "BTS",
            collectionName: "Proof",
            trackName: "Yet To Come",
            artworkUrl100: nil,
            primaryGenreName: "K-Pop",
            releaseDate: "2022-06-10",
            country: "KR",
            previewUrl: nil
        ),
        
        MusicItem(
            collectionId: 4,
            trackId: 104,
            artistName: "Yerin Baek",
            collectionName: "Every letter I sent you",
            trackName: "Maybe It's Not Our Fault",
            artworkUrl100: nil,
            primaryGenreName: "Indie",
            releaseDate: "2019-12-10",
            country: "KR",
            previewUrl: nil
        ),
        MusicItem(
            collectionId: 1,
            trackId: 101,
            artistName: "아이유",
            collectionName: "Palette",
            trackName: "밤편지",
            artworkUrl100: nil,
            primaryGenreName: "K-Pop",
            releaseDate: "2017-04-21",
            country: "KR",
            previewUrl: nil
        ),
        
        MusicItem(
            collectionId: 2,
            trackId: 102,
            artistName: "NewJeans",
            collectionName: "Get Up",
            trackName: "Super Shy",
            artworkUrl100: nil,
            primaryGenreName: "K-Pop",
            releaseDate: "2023-07-21",
            country: "KR",
            previewUrl: nil
        )
    ]
}
