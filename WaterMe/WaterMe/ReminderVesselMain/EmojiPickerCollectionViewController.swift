//
//  EmojiPickerViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/3/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

class EmojiPickerViewController: UICollectionViewController {
    
    class func newVC(emojiChosen: @escaping (String?, UIViewController) -> Void) -> UIViewController {
        let layout = UICollectionViewFlowLayout()
        let vc = EmojiPickerViewController(collectionViewLayout: layout)
        vc.emojiChosen = emojiChosen
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .formSheet
        return navVC
    }
    
    var emojiChosen: ((String?, UIViewController) -> Void)?
    private let data = ["💐", "🌷", "🌹", "🥀", "🌻", "🌼", "🌸", "🌺", "🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🍈", "🍒", "🍑", "🍍", "🥝", "🥑", "🍅", "🍆", "🥒", "🥕", "🌽", "🌶", "🥔", "🍠", "🌰", "🥜", "🌵", "🎄", "🌲", "🌳", "🌴", "🌱", "🌿", "☘️", "🍀", "🎍", "🎋", "🍃", "🍂", "🍁", "🍄", "🌾", "🥚", "🍳", "🐔", "🐧", "🐤", "🐣", "🐥", "🐓", "🦆", "🦃", "🐇", "🦀", "🦑", "🐙", "🦐", "🍤", "🐠", "🐟", "🐢", "🐍", "🦎", "🐝", "🍯", "🥐", "🍞", "🥖", "🧀", "🥗", "🍣", "🍱", "🍛", "🍚", "☕️", "🍵", "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🥛", "🐷", "🐽", "🐸", "🐒", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐛", "🦋", "🐌", "🐚", "🐞", "🐜", "🕷", "🦂", "🐡", "🐬", "🦈", "🐳", "🐋", "🐊", "🐆", "🐅", "🐃", "🐂", "🐄", "🦌", "🐪", "🐫", "🐘", "🦏", "🦍", "🐎", "🐖", "🐐", "🐏", "🐑", "🐕", "🐩", "🐈", "🕊", "🐁", "🐀", "🐿", "🐉", "🐲"]
    private var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Emoji"
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = cancel
        self.collectionView?.backgroundColor = .white
        self.collectionView?.alwaysBounceVertical = true
        self.collectionView?.register(EmojiPickerCollectionViewCell.nib, forCellWithReuseIdentifier: EmojiPickerCollectionViewCell.reuseID)
    }
    
    @objc private func cancelButtonTapped(_ sender: NSObject?) {
        self.emojiChosen?(nil, self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.data[indexPath.row]
        self.emojiChosen?(item, self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = EmojiPickerCollectionViewCell.reuseID
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath)
        let cell = _cell as? EmojiPickerCollectionViewCell
        cell?.configure(withEmojiString: self.data[indexPath.row])
        return _cell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let collectionWidth = self.collectionView?.bounds.width ?? 0
        let cellWidth = floor(collectionWidth / 5.0)
        
        self.flow?.itemSize = CGSize(width: cellWidth, height: cellWidth)
        self.flow?.minimumInteritemSpacing = 0
    }
}
