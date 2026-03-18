//
//  AlbumCoverCell.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/12/26.
//
import UIKit
import SnapKit
import Then
import Kingfisher

final class AlbumCoverCell: UICollectionViewCell {
    
    private let titleLabel = UILabel()
    private let dimView = UIView()
    private let albumCoverImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .systemGray5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumCoverImage.image = nil
        titleLabel.text = nil
    }
    
    private func configureLayout() {
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        contentView.addSubview(albumCoverImage)
        albumCoverImage.addSubview(dimView)
        albumCoverImage.addSubview(titleLabel)
        
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        albumCoverImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configure(with item: MusicItem) {
        titleLabel.text = item.collectionName
        // map으로 값 바꾸고 flatMap로 URL(string: $0)하면 옵셔널 값이라 옵셔널 벗기기 - nil일 경우 기본 이미지 보여줌
        let url = item.artworkUrl100
            .map { $0.replacingOccurrences(of: "100x100", with: "500x500") }
            .flatMap { URL(string: $0) }

        albumCoverImage.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "photo.trianglebadge.exclamationmark.fill")
        )
    }
}
