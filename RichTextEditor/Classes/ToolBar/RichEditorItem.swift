//
//  RichEditorItem.swift
//  RichTextEditor
//
//  Created by hamdan hashmi on 23/04/2020.
//  Copyright © 2020 Hamdan. All rights reserved.
//

import UIKit

public protocol RichEditorOption {
    var image: UIImage? { get }
    var title: String { get }
    func action(_ editor: RichEditorToolbar)
}

public struct RichEditorItem: RichEditorOption {
    public var image: UIImage?
    public var title: String
    public var handler: (RichEditorToolbar) -> Void
    
    public init(image: UIImage?, title: String, action: @escaping ((RichEditorToolbar) -> Void)) {
        self.image = image
        self.title = title
        handler = action
    }
    public func action(_ toolbar: RichEditorToolbar) {
        handler(toolbar)
    }
}

public enum RichEditorDefaultOption: RichEditorOption {
    case paragraph
    case clear
    case undo
    case redo
    case bold
    case italic
    case underline
    case checkbox
    case `subscript`
    case superscript
    case strike
    case textColor
    case textBackgroundColor
    case header(Int)
    case indent
    case outdent
    case orderedList
    case unorderedList
    case alignLeft
    case alignCenter
    case alignRight
    case hr
    case image
    case video
    case link
    case table
    case emptySpaceBetweenActions
    
    public static let all: [RichEditorDefaultOption] = [
        .paragraph,
         .clear,
        .undo, .redo,
        .bold, .italic, .underline,
        .checkbox, .subscript, .superscript, .strike,
        .textColor, .textBackgroundColor,
        .header(1), .header(2), .header(3), .header(4), .header(5), .header(6),
        .indent, outdent, orderedList, unorderedList,
        .alignLeft, .alignCenter, .alignRight, .hr, .image, .video, .link, .table
    ]
    
    public var image: UIImage? {
        switch self {
        case .paragraph: return IconType.specialCharacter.icon
        case .clear: return IconType.clearFormatting.icon
        case .undo: return IconType.undo.icon
        case .redo: return IconType.redo.icon
        case .bold: return IconType.bold.icon
        case .italic: return IconType.italic.icon
        case .underline: return IconType.underline.icon
        case .checkbox: return IconType.checkmark.icon
        case .subscript: return IconType.subscript.icon
        case .superscript: return IconType.superscript.icon
        case .strike: return IconType.strikethrough.icon
        case .textColor: return IconType.textColor.icon
        case .textBackgroundColor: return IconType.bgColor.icon
        case let .header(h):
            switch h {
            case 0: return IconType.heading.icon
            case 1: return IconType.headingH1.icon
            case 2: return IconType.headingH2.icon
            case 3: return IconType.headingH3.icon
            case 4: return IconType.headingH4.icon
            case 5: return IconType.headingH5.icon
            case 6: return IconType.headingH6.icon
            default:
                return IconType.heading.icon
            }
        case .indent: return IconType.indentLeft.icon
        case .outdent: return IconType.indentRight.icon
        case .orderedList: return IconType.listOrdered.icon
        case .unorderedList: return IconType.listUnordered.icon
        case .alignLeft: return IconType.alignLeft.icon
        case .alignCenter: return IconType.alignCenter.icon
        case .alignRight: return IconType.alignRight.icon
        case .hr: return IconType.linkBreak.icon
        case .image: return IconType.image.icon
        case .video: return IconType.video.icon
        case .link: return IconType.link.icon
        case .table: return IconType.grid.icon
        case .emptySpaceBetweenActions: return nil
        }
    }
    
    public var title: String {
        switch self {
        case .paragraph: return NSLocalizedString("paragraph", comment: "")
        case .clear: return NSLocalizedString("Clear", comment: "")
        case .undo: return NSLocalizedString("Undo", comment: "")
        case .redo: return NSLocalizedString("Redo", comment: "")
        case .bold: return NSLocalizedString("Bold", comment: "")
        case .italic: return NSLocalizedString("Italic", comment: "")
        case .underline: return NSLocalizedString("Underline", comment: "")
        case .checkbox: return NSLocalizedString("Checkbox", comment: "")
        case .subscript: return NSLocalizedString("Sub", comment: "")
        case .superscript: return NSLocalizedString("Super", comment: "")
        case .strike: return NSLocalizedString("Strike", comment: "")
        case .textColor: return NSLocalizedString("Color", comment: "")
        case .textBackgroundColor: return NSLocalizedString("BG Color", comment: "")
        case let .header(h): return NSLocalizedString("H\(h)", comment: "")
        case .indent: return NSLocalizedString("Indent", comment: "")
        case .outdent: return NSLocalizedString("Outdent", comment: "")
        case .orderedList: return NSLocalizedString("Ordered List", comment: "")
        case .unorderedList: return NSLocalizedString("Unordered List", comment: "")
        case .alignLeft: return NSLocalizedString("Left", comment: "")
        case .alignCenter: return NSLocalizedString("Center", comment: "")
        case .alignRight: return NSLocalizedString("Right", comment: "")
        case .hr: return NSLocalizedString("Horizontal Line", comment: "")
        case .image: return NSLocalizedString("Image", comment: "")
        case .video: return NSLocalizedString("Video", comment: "")
        case .link: return NSLocalizedString("Link", comment: "")
        case .table: return NSLocalizedString("Table", comment: "")
        case .emptySpaceBetweenActions: return ""
        }
    }
    
    public func action(_ toolbar: RichEditorToolbar) {
        toolbar.delegate?.actions(toolbar, action: self)
    }
}
