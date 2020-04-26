//
//  RichEditorViewJSActions.swift
//  RichTextEditor
//
//  Created by hamdan hashmi on 23/04/2020.
//  Copyright © 2020 Hamdan. All rights reserved.
//

import Foundation
import UIKit

extension RichEditorView {
    /// Runs some JavaScript on the WKWebView and returns the result
    internal func executeJS(_ js: String, handler: ((String) -> Void)? = nil) {
        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                print("WKWebViewJavascriptBridge Error: \(String(describing: error)) - JS: \(js)")
                handler?("")
                return
            }
            
            guard let handler = handler else { return }
            if let resultBool = result as? Bool {
                handler(resultBool ? "true" : "false")
                return
            }
            if let resultInt = result as? Int {
                handler("\(resultInt)")
                return
            }
            if let resultStr = result as? String {
                handler(resultStr)
                return
            }
            handler("")
        }
    }
}

// MARK: - Rich Text Editing public calls
extension RichEditorView {
    private func isContentEditable(handler _: @escaping (Bool) -> Void) {
        if isEditorLoaded {
            executeJS(.isContentEditable) { value in
                self.editingEnabledVar = Bool(value) ?? false
            }
        }
    }
    
    open func isEditingEnabled(handler: @escaping (Bool) -> Void) {
        isContentEditable(handler: handler)
    }
    
    public func getHtml(handler: @escaping (String) -> Void) {
        executeJS(.getHtml) { r in
            handler(r)
        }
    }
    
    /// Text representation of the data that has been input into the editor view, if it has been loaded.
    public func getText(handler: @escaping (String) -> Void) {
        executeJS(.getText) { r in
            handler(r)
        }
    }
    
    /// Returns selected text
    public func getSelectedText(handler: @escaping (String?) -> Void) {
        executeJS(.selectedText) { r in handler(r) }
    }
    
    /// The href of the current selection, if the current selection's parent is an anchor tag.
    /// Will be nil if there is no href, or it is an empty string.
    public func getSelectedHref(handler: @escaping (String?) -> Void) {
        hasRangeSelection(handler: { r in
            if !r {
                handler("")
            } else {
                self.executeJS(.getSelectedHref) { a in
                    handler(a)
                }
            }
        })
    }
    
    //"Range".
    public func hasRangeSelection(handler: @escaping (Bool) -> Void) {
        executeJS(.rangeSelectionExists) { r in
            handler(r == "true" ? true : false)
        }
    }
    
    /// Whether or not the selection has a type specifically of "Range" or "Caret".
    public func hasRangeOrCaretSelection(handler: @escaping (Bool) -> Void) {
        executeJS(.rangeOrCaretSelectionExists) { r in
            handler(r == "true" ? true : false)
        }
    }
    
    // MARK: Methods
    public func setParagraph() {
        executeJS(.paragraph)
    }
    
    public func removeFormat() {
        executeJS(.removeFormat)
    }
    
    public func setFontSize(_ size: Int) {
        executeJS(.setFontSize(size))
    }
    
    public func setEditorBackgroundColor(_ color: UIColor) {
        executeJS(.setEditorBackgroundColor(color))
    }
    
    public func undo() {
        executeJS(.undo)
    }
    
    public func redo() {
        executeJS(.redo)
    }
    
    public func bold() {
        executeJS(.bold)
    }
    
    public func italic() {
        executeJS(.italic)
    }
    
    public func subscriptText() {
        executeJS(.subscriptText)
    }
    
    public func superscript() {
        executeJS(.superscript)
    }
    
    public func strikethrough() {
        executeJS(.strikethrough)
    }
    
    public func underline() {
        executeJS(.underline)
    }
    
    public func setTextColor(_ color: UIColor) {
        executeJS(.prepareInsert)
        executeJS(.setTextColor(color))
    }
    
    public func setEditorFontColor(_ color: UIColor) {
        executeJS(.setEditorFontColor(color))
    }
    
    public func setTextBackgroundColor(_ color: UIColor) {
        executeJS(.prepareInsert)
        executeJS(.setTextBackgroundColor(color))
    }
    
    public func header(_ h: Int) {
        executeJS(.header(h))
    }
    
    public func indent() {
        executeJS(.indent)
    }
    
    public func outdent() {
        executeJS(.outdent)
    }
    
    public func orderedList() {
        executeJS(.orderedList)
    }
    
    public func unorderedList() {
        executeJS(.unorderedList)
    }
    
    public func blockquote() {
        executeJS(.blockquote)
    }
    
    public func alignLeft() {
        executeJS(.alignLeft)
    }
    
    public func alignCenter() {
        executeJS(.alignCenter)
    }
    
    public func alignRight() {
        executeJS(.alignRight)
    }
    
    public func insertHr() {
        executeJS(.insertHr)
    }
    
    public func insertImage(_ url: String, alt: String) {
        print(url.escaped)
        executeJS(.prepareInsert)
        executeJS(.insertImage(url, alt: alt))
    }
    
    public func insertVideo(video: String, isBase64: Bool = false) {
        // Remember, both poster and src can be base64 encoded
        executeJS(.prepareInsert)
        var theJS: String
        if isBase64 == true {
            // Assuming vidURL already in base64
            theJS = "<div><video class='video-js' controls preload='auto'  data-setup='{}'><source src='\(video)'></source></video></div>"
        } else {
            // Upload to server the base64 if isBase64 == true. Utilize the IDs and Video tags to your advantage. On Python web server, I use BeautifulSoup4. Use the base64 to save video in S3 and replace src with your new S3 video. Or you could just save in database.
            let uuid = UUID().uuidString
            theJS = "<div><video \(isBase64 ? "id='" + uuid + "'" : "") class='video-js' controls preload='auto' data-setup='{}'><source src='\(video)\(isBase64 ? "" : "#t=0.01")'></source></video></div>"
            // The time at the end is so that we can grab a thumbnail IF it's a link
        }
        executeJS(.insertHTML(theJS))
    }
    
    public func insertLink(href: String, text: String, title: String = "") {
        executeJS(.prepareInsert)
        executeJS(.insertLink(href: href, text: text, title: title))
    }
    
    public func focus() {
        KeyboardHandlers.allowDisplayingKeyboardWithoutUserAction()
        executeJS(.focus)
    }
    
    public func focus(at: CGPoint) {
        executeJS(.focus(at: at))
    }
    
    public func blur() {
        executeJS(.blur)
    }
    
    public func setCheckbox() {
        executeJS(.setCheckbox)
    }
    
    // MARK: Table functionalities
    
    public func insertTable(width: Int = 2, height: Int = 2) {
        executeJS(.prepareInsert)
        executeJS(.insertTable(width: width, height: height))
    }
    
    public func addRowToTable() {
        executeJS(.addRowToTable)
    }
    
    public func addColumnToTable() {
        executeJS(.addColumnToTable)
        
    }
    public func deleteRowFromTable() {
        executeJS(.deleteRowFromTable)
        
    }
    public func deleteColumnFromTable() {
        executeJS(.deleteColumnFromTable)
        
    }
}

extension RichEditorView {
    internal func performCommand(_ method: String) {
        if method.hasPrefix(.prefixReady) {
            // If loading for the first time
            // we have to set the content HTML to be displayed
            if !isEditorLoaded {
                isEditorLoaded = true
                setHTML(html)
                contentHTML = html
                contentEditable = editingEnabledVar
                placeholder = placeholderText
                lineHeight = DefaultInnerLineHeight
                delegate?.richEditor(self, actions: .didLoad)
            }
            updateHeight()
        } else if method.hasPrefix(.prefixInput) {
            scrollCaretToVisible()
            executeJS(.getHtml) { content in
                self.contentHTML = content
                self.updateHeight()
            }
        } else if method.hasPrefix(.prefixUpdateHeight) {
            updateHeight()
        } else if method.hasPrefix(.prefixUpdateWebView) {
            let str = contentHTML
            html = str
        } else if method.hasPrefix(.prefixFocus) {
            delegate?.richEditor(self, actions: .tookFocus)
        } else if method.hasPrefix(.prefixBlur) {
            delegate?.richEditor(self, actions: .lostFocus)
        } else if method.hasPrefix(.prefixAction) {
            executeJS(.getHtml) { [weak self] content in
                guard let self = self else { return }
                self.contentHTML = content
                // If there are any custom actions being called
                // We need to tell the delegate about it
                let actionPrefix: String = .prefixAction
                let range = method.range(of: actionPrefix)!
                let action = method.replacingCharacters(in: range, with: "")
                self.delegate?.richEditor(self, actions: .subActions(action))
            }
        }
    }
    
    private func updateHeight() {
        executeJS(.clientHeight) { heightString in
            let height = Int(heightString) ?? 0
            if self.editorHeight != height {
                self.editorHeight = height
            }
        }
    }
    
    internal func setHTML(_ value: String) {
        if isEditorLoaded {
            executeJS(.setHtml(value)) { _ in
                self.updateHeight()
            }
        }
    }
}
