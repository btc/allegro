//
//  OverviewView.swift
//  allegro
//
//  Created by Brian Tiger Chow on 3/5/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class OverviewView: UIView {

//    static let margin = DEFAULT_MARGIN_PTS
    static let margin: CGFloat = 15
    static let whitespace: CGFloat = 20

    let store: PartStore

    let measures: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = margin
        layout.minimumLineSpacing = margin
        layout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)

        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.register(MeasureViewCollectionCell.self, forCellWithReuseIdentifier: MeasureViewCollectionCell.reuseID)
        v.backgroundColor = .white
        
        return v
    }()

    let tap: UITapGestureRecognizer = {
        return UITapGestureRecognizer()
    }()

    init(store: PartStore) {
        self.store = store
        super.init(frame: .zero)

        store.subscribe(self)

        backgroundColor = .allegroPurple

        for v in [measures] {
            addSubview(v)
        }
        measures.dataSource = self
        measures.delegate = self
        measures.allowsSelection = true

        addGestureRecognizer(tap)
        tap.addTarget(self, action: #selector(tapped))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        measures.frame = bounds
    }

    func tapped(sender: UITapGestureRecognizer) {
        
    }
}


extension OverviewView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let rawCell = collectionView.dequeueReusableCell(withReuseIdentifier: MeasureViewCollectionCell.reuseID, for: indexPath)
        guard let cell = rawCell as? MeasureViewCollectionCell else { return rawCell }
        cell.store = store
        cell.index = indexPath.item
        cell.subviews.forEach { $0.isUserInteractionEnabled = false } // to prevent user from interacting with the measures
        
        let leftWhitespace = UIView(frame: CGRect(x: cell.bounds.minX,
                                                  y: cell.bounds.minY,
                                                  width: OverviewView.whitespace,
                                                  height: cell.bounds.height))
        leftWhitespace.backgroundColor = .white
        cell.addSubview(leftWhitespace)
        
        let rightWhitespace = UIView(frame: CGRect(x: cell.bounds.width - OverviewView.whitespace,
                                                   y: cell.bounds.minY,
                                                   width: OverviewView.whitespace,
                                                   height: cell.bounds.height))
        rightWhitespace.backgroundColor = .white
        cell.addSubview(rightWhitespace)
        
        cell.layer.borderColor = UIColor.allegroDarkGray.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return store.measureCount
    }
}

extension OverviewView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        store.currentMeasure = indexPath.item
        store.view = .measure
    }
}

extension OverviewView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthReservedForContent = bounds.width - 3 * type(of: self).margin
        let heightReservedForContent = bounds.height - 3 * type(of: self).margin
        return CGSize(width: widthReservedForContent / 2, height: heightReservedForContent / 2)
    }
}


extension OverviewView: PartStoreObserver {
    func partStoreChanged() {
        measures.reloadData()
    }
}
