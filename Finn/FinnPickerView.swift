//
//  FinnPickerView.swift
//  Finn
//
//  Created by Gareth Jones  on 5/15/15.
//  Copyright (c) 2015 garethpaul. All rights reserved.
//

import Foundation
import UIKit


class FinnPickerView : MDCSwipeToChooseView {
    var restaurant: Restaurant?
    var res: Restaurant?

    var infoView: UIView = UIView()

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(frame: CGRect, restaurant: Restaurant, options: MDCSwipeToChooseViewOptions) {
        super.init(frame: frame, options: options)

        self.restaurant = restaurant

        // Setup resizing masks
        self.autoresizingMask = UIViewAutoresizing.FlexibleHeight |
            UIViewAutoresizing.FlexibleWidth |
            UIViewAutoresizing.FlexibleBottomMargin

        self.imageView.autoresizingMask = self.autoresizingMask
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill

        self.imageView.frame = CGRectMake(
            2,
            2,
            CGRectGetWidth(self.bounds) - 4,
            CGRectGetHeight(self.bounds) - 4
        )

        constructInfoView()
        loadImageView()
    }

    func constructInfoView() {
        let infoViewHeight: CGFloat = 150

        let infoViewFrame: CGRect = CGRectMake(
            0,
            CGRectGetHeight(self.bounds) - infoViewHeight,
            CGRectGetWidth(self.bounds),
            infoViewHeight
        )

        infoView = UIView(frame: infoViewFrame)
        infoView.backgroundColor = UIColor.whiteColor()
        infoView.clipsToBounds = true
        infoView.autoresizingMask = UIViewAutoresizing.FlexibleWidth |
            UIViewAutoresizing.FlexibleTopMargin;

        self.addSubview(infoView)

        constructNameLabel()
    }

    func loadImageView() {
        let pic = Picture()
        let url_string = restaurant!.image
        pic.get(NSURL(string: url_string)!, handler: {image, error in
            let newImg = image
            self.imageView.image = image
        })


    }

    func constructNameLabel() {
        let nameLabel: UILabel = UILabel(frame: infoView.bounds)
        nameLabel.text = restaurant!.name
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.font = UIFont.systemFontOfSize(20.0)
        nameLabel.adjustsFontSizeToFitWidth = true

        self.infoView.addSubview(nameLabel)
            
        }
}

