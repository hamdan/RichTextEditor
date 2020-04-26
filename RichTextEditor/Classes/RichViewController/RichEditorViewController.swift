//
//  RichViewController.swift
//  RichTextEditor
//
//  Created by hamdan hashmi on 26/04/2020.
//  Copyright © 2020 Hamdan. All rights reserved.
//

import UIKit

 public protocol RichEditorViewControllerDelegate {
    func exportHtml(_ html: String)
}
public final class RichEditorViewController: UIViewController {

    public var delegate: RichEditorViewControllerDelegate?
    public var getHtml: String?
    var richTextEditor: RichEditorView?
    let html: String
    public init(html: String, delegate: RichEditorViewControllerDelegate? = nil) {
        self.html = html
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44), delegate: self)
        let richTextEditor = RichEditorView(frame: self.view.frame, delegate: self, editingEnabled: true, toolbar: toolbar)
        self.richTextEditor = richTextEditor
        self.view.addSubview(richTextEditor)
        self.richTextEditor?.html = html
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
        target: self,
        action: #selector(pressSave))
    }
    
    @objc func pressSave() {
        
        if let html = getHtml {
            print(html)
            delegate?.exportHtml(html)
        }
        
    }
}

extension RichEditorViewController: RichEditorDelegate {
    public func richEditor(_ editor: RichEditorView, actions: RichEditorActions) {
        switch actions {
        case let .contentDidChange(content):
             // This is meant to act as a text cap
             if content.count > 40000 {
                 editor.html = getHtml ?? ""
             } else {
                 getHtml = content
             }
        case .didLoad, .tookFocus, .lostFocus: break
        case let .heightDidChange(height): print(height)
        case let .shouldInteractWith(url): print(url)
        case .subActions(_): break
        }
    }
}

extension RichEditorViewController: RichEditorToolbarDelegate {
    public func actions(_ toolbar: RichEditorToolbar, action: RichEditorDefaultOption) {
        switch action {
        case .paragraph: richTextEditor?.setParagraph()
        case .clear: richTextEditor?.removeFormat()
        case .undo: richTextEditor?.undo()
        case .redo: richTextEditor?.redo()
        case .bold: richTextEditor?.bold()
        case .italic: richTextEditor?.italic()
        case .underline: richTextEditor?.underline()
        case .checkbox: richTextEditor?.setCheckbox()
        case .subscript: richTextEditor?.subscriptText()
        case .superscript: richTextEditor?.superscript()
        case .strike: richTextEditor?.strikethrough()
        case .textColor: richTextEditor?.setTextColor(.red)
        case .textBackgroundColor: break
        case let .header(h): richTextEditor?.header(h)
        case .indent: richTextEditor?.indent()
        case .outdent: richTextEditor?.outdent()
        case .orderedList: richTextEditor?.orderedList()
        case .unorderedList: richTextEditor?.unorderedList()
        case .alignLeft: richTextEditor?.alignLeft()
        case .alignCenter: richTextEditor?.alignCenter()
        case .alignRight: richTextEditor?.alignRight()
        case .hr: richTextEditor?.insertHr()
        case .image: insertImage()
        case .video: break
        case .link: insertLink()
        case .table: richTextEditor?.insertTable(width: 4, height: 4)
        }
    }
    
    func insertImage() {
        let alertController = UIAlertController(title: "Enter Image link and text", message: "You can leave the text empty to only show a clickable link", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Insert", style: .default) { [weak self] _ in
            let link = alertController.textFields?[0].text
            let text = alertController.textFields?[1].text
            self?.richTextEditor?.insertImage(link!, alt: text ?? link!)
            self?.richTextEditor?.focus()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.richTextEditor?.focus()
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        confirmAction.isEnabled = false
        let linkPH = "Image URL (required)"
        let txtPH = "Alt"
        alertController.addTextField { textField in
            textField.placeholder = linkPH
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
                if self.isURLValid(url: textField.text) == true {
                    confirmAction.isEnabled = textField.hasText
                } else {
                    confirmAction.isEnabled = false
                }
            }
        }
        alertController.addTextField { textField in textField.placeholder = txtPH }
        
    }
    func insertLink() {
        let alertController = UIAlertController(title: "Enter link and text", message: "You can leave the text empty to only show a clickable link", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Insert", style: .default) { [weak self]  _ in
            var link = alertController.textFields?[0].text
            let text = alertController.textFields?[1].text
            if link?.last != "/" { link = link! + "/" }
            self?.richTextEditor?.insertLink(href: link!, text: text ?? link!)
            self?.richTextEditor?.focus()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.richTextEditor?.focus()
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        confirmAction.isEnabled = false
        let linkPH = "Link (required)"
        let txtPH = "Text (Clickable text that redirects to link)"
        richTextEditor?.hasRangeSelection(handler: { r in
            if r == true {
                alertController.addTextField { textField in
                    textField.placeholder = linkPH
                    self.richTextEditor?.getSelectedHref(handler: { a in
                        if a?.last != "/" {
                            textField.text = nil
                        } else {
                            if self.isURLValid(url: a) == true {
                                textField.text = a
                            }
                        }
                    })
                    NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
                        if self.isURLValid(url: textField.text) == true {
                            confirmAction.isEnabled = textField.hasText
                        } else {
                            confirmAction.isEnabled = false
                        }
                    }
                }
                alertController.addTextField { textField in
                    textField.placeholder = txtPH
                    self.richTextEditor?.getSelectedText(handler: { a in
                        textField.text = a
                    })
                }
            } else {
                alertController.addTextField { textField in
                    textField.placeholder = linkPH
                    NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
                        if self.isURLValid(url: textField.text) == true {
                            confirmAction.isEnabled = textField.hasText
                        } else {
                            confirmAction.isEnabled = false
                        }
                    }
                }
                alertController.addTextField { textField in textField.placeholder = txtPH }
            }
        })
    }
    
    func isURLValid(url: String?) -> Bool {
        guard let urlString = url else { return false }
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
}
