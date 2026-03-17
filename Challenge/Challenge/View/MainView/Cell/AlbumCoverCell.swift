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
    
    static let identifier = "AlbumCoverCell"
    
    let albumCoverImage = UIImageView().then {
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
    }
    
    private func configureLayout() {
        contentView.addSubview(albumCoverImage)
        albumCoverImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(with item: MusicItem) {
        if let imageURL = item.artworkUrl100 {
            let highQualityURL = imageURL.replacingOccurrences(of: "100x100" , with: "500x500")
            albumCoverImage.kf.setImage(with: URL(string: highQualityURL))
        } else {
            albumCoverImage.image = UIImage(systemName: "photo.trianglebadge.exclamationmark.fill")
        }
    }
}
