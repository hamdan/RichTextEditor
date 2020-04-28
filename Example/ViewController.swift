//
//  ViewController.swift
//  Example
//
//  Created by hamdan hashmi on 23/04/2020.
//  Copyright © 2020 Hamdan. All rights reserved.
//

import UIKit
import RichTextEditor

class ViewController: UIViewController, RichEditorViewControllerDelegate {
    var richTextEditor: RichEditorView?
    var prevHtml = "What I'll usually do for focus and unfocus is similar to what Google Docs does. The insert link functionality is similar to Reddit's except I use a UIAlertController. There are some added and altered functionality like running your custom JS; you will just have to learn what goes on with this package, but it's a quick learn. <b>Good luck!</b> If you have any issues, Yoom will help out, so long as those issues are opened in this repo. Credits still go out to cjwirth and C. Bess </br>" +
    "<img src=\"http://www.pngmart.com/files/7/Red-Smoke-Transparent-Images-PNG.png\" alt=\"\" width=\"160\" height=\"109\"> <div class=\"section-heading\"><div class=\"section-heading-left\"><svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" class=\"note-icon\"><path fill=\"#000\" d=\"M6.9 15h6.67a.9.9 0 0 1 0 1.8H6.9a.9.9 0 1 1 0-1.8zm0-4.2h10.2a.9.9 0 1 1 0 1.8H6.9a.9.9 0 0 1 0-1.8zm0-4.2h10.2a.9.9 0 1 1 0 1.8H6.9a.9.9 0 0 1 0-1.8z\" fill-rule=\"evenodd\"></path></svg><h4></h4></div></div>"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let richTextEditor = RichEditorView(
            frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 200),
            editingEnabled: false
        )
        richTextEditor.html = prevHtml
        self.richTextEditor = richTextEditor
        self.view.addSubview(richTextEditor)
        
        let openRichTextEditor = UIButton(frame: CGRect(x: 50, y: 250, width: 200, height: 44))
        openRichTextEditor.setTitle("open", for: .normal)
        openRichTextEditor.addTarget(self, action:#selector(buttonClicked), for: .touchUpInside)
        openRichTextEditor.backgroundColor = .red
        self.view.addSubview(openRichTextEditor)
        
        
    }
    
    @objc func buttonClicked() {
        let redos = RichEditorDefaultOption.self
        let space = redos.emptySpaceBetweenActions
        let options = [redos.undo, space , redos.redo, space,
                       redos.bold, space , redos.italic, space,
                       redos.underline, space, redos.header(1), space,
                       redos.header(2), space, redos.header(3), space,
                       redos.orderedList, space, redos.unorderedList]
        let controller = RichEditorViewController(html: prevHtml, delegate: self, options: options)
        let controllerNav = UINavigationController(rootViewController: controller)
        present(controllerNav, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func exportHtml(_ html: String) {
        dismiss(animated: true)
        prevHtml = html
        richTextEditor?.html = prevHtml
    }
}
