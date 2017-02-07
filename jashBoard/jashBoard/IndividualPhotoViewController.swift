//
//  IndividualPhotoViewController.swift
//  jashBoard
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit
import SnapKit

class IndividualPhotoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        var tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        self.view.backgroundColor = .yellow
        
        setupViewHierarchy()
        configureConstraints()
    }
    
    // MARK: - Setup
    private func setupViewHierarchy() {
        self.view.addSubview(photoImageView)
        self.view.addSubview(upvoteButton)
        self.view.addSubview(downvoteButton)
        self.view.addSubview(upvoteNumberLabel)
        self.view.addSubview(downvoteNumberLabel)
    }
    
    private func configureConstraints() {
        self.edgesForExtendedLayout = []
        
        // image
        photoImageView.snp.makeConstraints { (view) in
            view.top.leading.trailing.equalToSuperview()
            view.bottom.equalTo(self.view.snp.centerY)
        }
        
        // labels
        upvoteNumberLabel.snp.makeConstraints { (view) in
            view.leading.equalToSuperview()
            view.bottom.equalTo(self.view.snp.centerY)
            view.trailing.equalTo(self.view.snp.centerX)
        }
        
        upvoteNumberLabel.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview()
            view.bottom.equalTo(self.view.snp.centerY)
            view.leading.equalTo(self.view.snp.centerX)
        }
        
        // buttons
        upvoteButton.snp.makeConstraints { (view) in
            view.leading.equalToSuperview()
            view.bottom.equalTo(upvoteNumberLabel.snp.top)
            view.trailing.equalTo(self.view.snp.centerX)
        }
        
        downvoteButton.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview()
            view.bottom.equalTo(upvoteNumberLabel.snp.top)
            view.leading.equalTo(self.view.snp.centerX)
        }
        
        // tableView
        tableView.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.top.equalTo(self.view.snp.centerY)
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - TableView Delegates

    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }


    // MARK: - Views
    
    // logo
    internal lazy var photoImageView: UIImageView = {
        let image = UIImage(named: "logo")
        let imageView: UIImageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // buttons
    internal lazy var upvoteButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setTitle("↑", for: .normal)
        button.backgroundColor = JashColors.primaryColor
        
        // TO DO: Background needs to be trasnlucent
        button.backgroundColor?.withAlphaComponent(0.01)
        //        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightMedium)
        button.setTitleColor(JashColors.accentColor, for: .normal)
        button.contentEdgeInsets = UIEdgeInsetsMake(8.0, 24.0, 8.0, 24.0)
        return button
    }()
    
    internal lazy var downvoteButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setTitle("↓", for: .normal)
        button.backgroundColor = JashColors.primaryColor
        button.backgroundColor?.withAlphaComponent(0.01)
        //        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightMedium)
        button.setTitleColor(JashColors.accentColor, for: .normal)
        button.contentEdgeInsets = UIEdgeInsetsMake(8.0, 24.0, 8.0, 24.0)
        return button
    }()
    
    // labels
    internal lazy var upvoteNumberLabel: UILabel = {
        let label = UILabel()
        //    label.font = UIFont.systemFont(ofSize: self.subLabelFontSize)
        label.textColor = JashColors.accentColor
        label.backgroundColor = JashColors.primaryColor
        label.text = "0"
        return label
    }()
    
    internal lazy var downvoteNumberLabel: UILabel = {
        let label = UILabel()
        //    label.font = UIFont.systemFont(ofSize: self.subLabelFontSize)
        label.textColor = JashColors.accentColor
        label.backgroundColor = JashColors.primaryColor
        label.text = "0"
        return label
    }()
}
