//
//  RichEditorView.swift
//  RichTextEditor
//
//  Created by hamdan hashmi on 23/04/2020.
//  Copyright © 2020 Hamdan. All rights reserved.
//

import UIKit
import WebKit

public enum RichEditorActions {
    case heightDidChange(_ height: Int)
    case contentDidChange(_ content: String)
    case shouldInteractWith(_ url: URL)
    case subActions(_ action: String)
    case didLoad
    case lostFocus
    case tookFocus
    case viewDidTap
}
/// RichEditorDelegate defines callbacks for the delegate of the RichEditorView
 public protocol RichEditorDelegate {
    func richEditor(_ editor: RichEditorView, actions: RichEditorActions)
}

/// The value we hold in order to be able to set the line height before the JS completely loads.
internal let DefaultInnerLineHeight: Int = 28

/// RichEditorView is a UIView that displays richly styled text, and allows it to be edited in a WYSIWYG fashion.
@objcMembers open class RichEditorView: UIView, UIScrollViewDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {
    /// should ShowKeyboard on appear
    open var shouldShowKeyboard: Bool = true
    /// The delegate that will receive callbacks when certain actions are completed.
    open var delegate: RichEditorDelegate?
    
    /// Input accessory view to display over they keyboard.
    /// Defaults to nil
    open override var inputAccessoryView: UIView? {
        get { return webView.accessoryView }
        set { webView.accessoryView = newValue }
    }
    
    open private(set) var webView: RichEditorWebView
    
    // Whether or not scroll is enabled on the view.
    open var isScrollEnabled: Bool = true {
        didSet {
            webView.scrollView.isScrollEnabled = isScrollEnabled
        }
    }
    
    // Whether or not to allow user input in the view.
    open var editingEnabled: Bool = false {
        didSet { contentEditable = editingEnabled }
    }
    
    private let tapRecognizer = UITapGestureRecognizer()
    
    // The content HTML of the text being displayed.
    // Is continually updated as the text is being edited.
    open internal(set) var contentHTML: String = "" {
        didSet {
            delegate?.richEditor(self, actions: .contentDidChange(contentHTML))
        }
    }
    
    // The internal height of the text being displayed.
    // Is continually being updated as the text is edited.
    open internal(set) var editorHeight: Int = 0 {
        didSet {
            delegate?.richEditor(self, actions: .heightDidChange(editorHeight))
        }
    }
    
    // The line height of the editor. Defaults to 28.
    open internal(set) var lineHeight: Int = DefaultInnerLineHeight {
        didSet {
            executeJS(.setLineHeight(lineHeight))
        }
    }
    
    // Whether or not the editor has finished loading or not yet.
    internal var isEditorLoaded = false
    
    // Value that stores whether or not the content
    // should be editable when the editor is loaded.
    internal var editingEnabledVar = true
    
    // The HTML that is currently loaded in the editor view,
    // if it is loaded. If it has not been loaded yet, it is the
    // HTML that will be loaded into the editor view once it finishes initializing.
    public var html: String = "" {
        didSet {
            setHTML(html)
        }
    }
    

    internal var placeholderText: String = ""
    // The placeholder text that should be shown when there is no user input.
    open var placeholder: String {
        get { return placeholderText }
        set {
            placeholderText = newValue
            if isEditorLoaded {
                executeJS(.setPlaceholderText(newValue))
            }
        }
    }
    
    internal var contentEditable: Bool = false {
        didSet {
            editingEnabledVar = contentEditable
            if isEditorLoaded {
                executeJS(
                    .setContentEditable(
                        contentEditable ? "true" : "false"
                    )
                )
            }
        }
    }
    
    // MARK: Initialization
    public convenience init(frame: CGRect,
                            delegate: RichEditorDelegate? = nil,
                            editingEnabled: Bool = false,
                            placeholder: String = "Press to start typing",
                            toolbar: RichEditorToolbar? = nil) {
        self.init(frame: frame)
        self.delegate = delegate
        self.editingEnabled = editingEnabled
        self.editingEnabledVar = editingEnabled
        self.placeholder = placeholder
        self.inputAccessoryView = toolbar
        self.shouldShowKeyboard = editingEnabled
        setup()
    }
    
    public override init(frame: CGRect) {
        webView = RichEditorWebView()
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        webView = RichEditorWebView()
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        configureWebView()
        tapRecognizer.addTarget(self, action: #selector(viewWasTapped))
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
    }
    
    private func configureWebView() {
        // configure webview
        webView.frame = frame
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.configuration.dataDetectorTypes = WKDataDetectorTypes()
        webView.scrollView.isScrollEnabled = isScrollEnabled
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.bounces = false
        webView.scrollView.delegate = self
        webView.scrollView.clipsToBounds = true
        webView.isOpaque = false
        addSubview(webView)
        if let filePath = Bundle(for: RichEditorView.self).path(forResource: "rich_editor", ofType: "html") {
            let url = URL(fileURLWithPath: filePath, isDirectory: false)
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
    
    // MARK: - Responder Handling
    // Called by the UITapGestureRecognizer when the user taps the view
    @objc private func viewWasTapped() {
        delegate?.richEditor(self, actions: .viewDidTap)
        if !webView.isFirstResponder {
           // focus()
            let point = tapRecognizer.location(in: webView)
            focus(at: point)
        }
    }
    
    open override func becomeFirstResponder() -> Bool {
        if !webView.isFirstResponder {
            focus()
            return true
        } else {
            return false
        }
    }
    
    open override func resignFirstResponder() -> Bool {
        blur()
        return true
    }
}

// MARK: UIScrollViewDelegate
extension RichEditorView {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // We use this to keep the scroll view from changing its offset when the keyboard comes up
        if !isScrollEnabled {
            scrollView.bounds = webView.frame
        }
    }
    
    // Scrolls the editor to a position where the caret is visible.
    // Called repeatedly to make sure the caret is always visible when inputting text.
    // Works only if the `lineHeight` of the editor is available.
    internal func scrollCaretToVisible() {
        let scrollView = webView.scrollView
        
        getClientHeight(handler: { clientHeight in
            let contentHeight = clientHeight > 0 ? CGFloat(clientHeight) : scrollView.frame.height
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
            
            // Maybe find a better way to get the cursor height
            self.getLineHeight(handler: { lh in
                let lineHeight = CGFloat(lh)
                let cursorHeight = lineHeight - 4
                self.relativeCaretYPosition(handler: { r in
                    let visiblePosition = CGFloat(r)
                    var offset: CGPoint?
                    
                    if visiblePosition + cursorHeight > scrollView.bounds.size.height {
                        // Visible caret position goes further than our bounds
                        offset = CGPoint(x: 0, y: (visiblePosition + lineHeight) - scrollView.bounds.height + scrollView.contentOffset.y)
                    } else if visiblePosition < 0 {
                        // Visible caret position is above what is currently visible
                        let amount = scrollView.contentOffset.y + visiblePosition
                        //amount = amount < 0 ? 0 : amount
                        offset = CGPoint(x: scrollView.contentOffset.x, y: amount)
                    }
                    
                    if let offset = offset {
                        scrollView.setContentOffset(offset, animated: true)
                    }
                })
            })
        })
    }
    
    private func getLineHeight(handler: @escaping (Int) -> Void) {
        guard isEditorLoaded else { return  handler(DefaultInnerLineHeight) }
        executeJS(.getLineHeight) { r in
            handler(Int(r) ?? DefaultInnerLineHeight)
        }
    }
}

// MARK: UIGestureRecognizerDelegate
extension RichEditorView {
    // Delegate method for our UITapGestureDelegate.
    public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: WKWebViewDelegate
extension RichEditorView {

    public func webView(_: WKWebView, didFinish _: WKNavigation!) {
        print("finish to load")
        if shouldShowKeyboard {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.focus()
            }
        }
    }
    
    public func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Handle pre-defined editor actions
        if navigationAction.request.url?.absoluteString.hasPrefix(.callbackPrefix) == true {
            // When we get a callback, we need to fetch the command queue to run the commands
            // It comes in as a JSON array of commands that we need to parse
            executeJS(.getCommandQueue) { commands in
                if let data = commands.data(using: .utf8) {
                    let jsonCommands: [String]
                    do {
                        jsonCommands = try JSONSerialization.jsonObject(with: data) as? [String] ?? []
                    } catch {
                        jsonCommands = []
                        NSLog("RichEditorView: Failed to parse JSON Commands")
                    }
                    jsonCommands.forEach(self.performCommand)
                }
            }
            return decisionHandler(WKNavigationActionPolicy.cancel)
        }
        
        // User is tapping on a link, so we should react accordingly
        if navigationAction.navigationType == .linkActivated,
            let url = navigationAction.request.url {
            delegate?.richEditor(self, actions: .shouldInteractWith(url))
            return decisionHandler(WKNavigationActionPolicy.allow)
        }
        return decisionHandler(WKNavigationActionPolicy.allow)
    }
}

extension RichEditorView {    
    // The position of the caret relative to the currently shown content.
    fileprivate func relativeCaretYPosition(handler: @escaping (Int) -> Void) {
        executeJS(.getRelativeCaretYPosition) { r in
            handler(Int(r) ?? 0)
        }
    }
    
    fileprivate func updateHeight() {
        executeJS(.clientHeight) { heightString in
            let height = Int(heightString) ?? 0
            if self.editorHeight != height {
                self.editorHeight = height
            }
        }
    }
    // The inner height of the editor div.
    private func getClientHeight(handler: @escaping (Int) -> Void) {
        executeJS(.clientHeight) { r in
            handler(Int(r) ?? 0)
        }
    }
}
