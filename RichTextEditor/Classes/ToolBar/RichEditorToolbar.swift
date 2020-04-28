//
//  RichEditorToolbar.swift
//  RichTextEditor
//
//  Created by hamdan hashmi on 23/04/2020.
//  Copyright © 2020 Hamdan. All rights reserved.
//

import UIKit

// RichEditorToolbarDelegate is a protocol for the RichEditorToolbar.
// Used to receive actions that need extra work to perform (eg. display some UI)
public protocol RichEditorToolbarDelegate {
    func actions(_ toolbar: RichEditorToolbar, action: RichEditorDefaultOption)
}


@objcMembers open class RichEditorToolbar: UIView {
    public var delegate: RichEditorToolbarDelegate?
    public var options: [RichEditorOption] = [] {
        didSet {
            updateToolbar()
        }
    }
    public var barTintColor: UIColor? {
        get { return backgroundToolbar.barTintColor }
        set { backgroundToolbar.barTintColor = newValue }
    }
    
    private var toolbarScroll: UIScrollView
    private var toolbar: UIToolbar
    private var backgroundToolbar: UIToolbar
    
    
    public convenience init(frame: CGRect,
                            delegate: RichEditorToolbarDelegate? = nil,
                            options: [RichEditorDefaultOption] = RichEditorDefaultOption.all) {
        self.init(frame: frame)
        self.delegate = delegate
        self.options = options
        setup()
        
    }
    
    public override init(frame: CGRect) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar(frame: frame)
        backgroundToolbar = UIToolbar(frame: frame)
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = .flexibleWidth
        backgroundColor = .clear
        
        backgroundToolbar.frame = bounds
        backgroundToolbar.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        toolbar.autoresizingMask = .flexibleWidth
        toolbar.backgroundColor = .clear
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolbarScroll.frame = bounds
        toolbarScroll.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        toolbarScroll.showsHorizontalScrollIndicator = false
        toolbarScroll.showsVerticalScrollIndicator = false
        toolbarScroll.backgroundColor = .clear
        toolbarScroll.addSubview(toolbar)
        addSubview(backgroundToolbar)
        addSubview(toolbarScroll)
        updateToolbar()
    }
    
    private func updateToolbar() {
        var buttons = [UIBarButtonItem]()
        options.forEach { option in
            let handler = { [weak self] in
                if let strongSelf = self {
                    option.action(strongSelf)
                }
            }
            
            if let image = option.image {
                let button = RichBarButtonItem(image: image, handler: handler)
                buttons.append(button)
            } else {
                let title = option.title
                let button = RichBarButtonItem(title: title, handler: handler)
                buttons.append(button)
            }
        }
        toolbar.items = buttons
        
        let defaultIconWidth: CGFloat = 28
        let barButtonItemMargin: CGFloat = 12
        let width: CGFloat = buttons.reduce(0) { sofar, new in
            if let view = new.value(forKey: "view") as? UIView {
                return sofar + view.frame.size.width + barButtonItemMargin
            } else {
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        if width < frame.size.width {
            toolbar.frame.size.width = frame.size.width + barButtonItemMargin
        } else {
            toolbar.frame.size.width = width + barButtonItemMargin
        }
        toolbar.frame.size.height = 44
        toolbarScroll.contentSize.width = width
    }
}


@objcMembers open class RichBarButtonItem: UIBarButtonItem {
    open var actionHandler: (() -> Void)?
    
    public convenience init(image: UIImage? = nil, handler: (() -> Void)? = nil) {
        self.init(image: image, style: .plain, target: nil, action: nil)
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
    }
    
    public convenience init(title: String = "", handler: (() -> Void)? = nil) {
        self.init(title: title, style: .plain, target: nil, action: nil)
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
    }
    
    func buttonWasTapped() {
        actionHandler?()
    }
}
