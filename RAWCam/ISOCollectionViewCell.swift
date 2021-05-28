//
//  ISOCollectionViewCell.swift
//  RAWCam
//
//  Created by thilina shashimal senarath on 5/28/21.
//

import UIKit

class ISOCollectionViewCell: UICollectionViewCell {
    static let identifier = "ISOCollectionViewCell"
    
    private let value: UILabel = {
       let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
       label.textColor = UIColor.yellow
       label.font =  UIFont(name: "Helvetica-Bold", size: 10)
        label.textAlignment = .center
       return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 5
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.yellow.cgColor
        contentView.layer.masksToBounds = true
        contentView.addSubview(self.value)
        self.value.layer.masksToBounds = true
        self.value.text = "100"
        self.value.translatesAutoresizingMaskIntoConstraints =  false
        
    }
    func setValue(value:Int){
        self.value.text = String(value)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.value.center = CGPoint(x: contentView.frame.width/2, y: contentView.frame.height/2)
//        NSLayoutConstraint.activate([
//            self.value.topAnchor.constraint(equalTo: contentView.topAnchor),
//            self.value.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            self.value.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            self.value.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//
//        ])
        

    }
}
