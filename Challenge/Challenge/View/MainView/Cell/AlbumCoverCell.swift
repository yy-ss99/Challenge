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
        let imageURL = "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/b7/d7/f7/b7d7f7f9-c428-ceda-59da-9ab0b112ca88/5059460232280.jpg/100x100bb.jpg"
        albumCoverImage.kf.setImage(with: URL(string: imageURL))
    }
}
