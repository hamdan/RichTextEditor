//
//  RichEditorWebview.swift
//  RichTextEditor
//
//  Created by hamdan hashmi on 23/04/2020.
//  Copyright © 2020 Hamdan. All rights reserved.
//

import UIKit
import WebKit

public class RichEditorWebView: WKWebView {
    public var accessoryView: UIView?
    public override var inputAccessoryView: UIView? {
        return accessoryView
    }
}
