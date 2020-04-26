//
//  JsActions.swift
//  RichTextEditor
//
//  Created by hamdan hashmi on 23/04/2020.
//  Copyright © 2020 Hamdan. All rights reserved.
//

import Foundation
import UIKit

extension String {
    //Prefix
    public static let prefixReady = "ready"
    public static let prefixInput = "input"
    public static let prefixUpdateHeight = "updateHeight"
    public static let prefixUpdateWebView = "updateWebView"
    public static let prefixFocus = "focus"
    public static let prefixBlur = "blur"
    public static let prefixAction = "action/"
    
    // actions
    public static let callbackPrefix = "re-callback://"
    public static let getLineHeight = "RE.getLineHeight()"
    
    public static let indent = "RE.setIndent()"
    public static let outdent = "RE.setOutdent()"
    public static let orderedList = "RE.setOrderedList()"
    public static let unorderedList = "RE.setUnorderedList()"
    public static let blockquote = "RE.setBlockquote()"
    public static let alignLeft = "RE.setJustifyLeft()"
    public static let alignCenter = "RE.setJustifyCenter()"
    public static let alignRight = "RE.setJustifyRight()"
    public static let getHtml = "RE.getHtml()"
    public static let isContentEditable = "RE.editor.isContentEditable"
    public static let getCommandQueue = "RE.getCommandQueue()"
    public static let getRelativeCaretYPosition = "RE.getRelativeCaretYPosition()"
    public static let clientHeight = "document.getElementById('editor').clientHeight"
    public static let getText = "RE.getText()"
    public static let selectedText = "RE.selectedText()"
    public static let getSelectedHref = "RE.getSelectedHref()"
    public static let rangeSelectionExists = "RE.rangeSelectionExists()"
    public static let rangeOrCaretSelectionExists = "RE.rangeOrCaretSelectionExists()"
    public static let removeFormat = "RE.removeFormat()"
    public static let paragraph = "RE.setParagraph()"
    public static let undo = "RE.undo()"
    public static let redo = "RE.redo()"
    public static let bold = "RE.setBold()"
    public static let italic = "RE.setItalic()"
    public static let subscriptText = "RE.setSubscript()"
    public static let superscript = "RE.setSuperscript()"
    public static let strikethrough = "RE.setStrikeThrough()"
    public static let underline = "RE.setUnderline()"
    public static let prepareInsert = "RE.prepareInsert()"
    public static let setCheckbox = "RE.setCheckbox('\(UUID().uuidString.prefix(8))')"
    public static let focus = "RE.focus()"
    public static let blur = "RE.blurFocus()"
    public static let addRowToTable = "RE.addRowToTable()"
    public static let addColumnToTable = "RE.addColumnToTable()"
    public static let deleteRowFromTable = "RE.deleteRowFromTable()"
    public static let deleteColumnFromTable = "RE.deleteColumnFromTable()"
    public static let insertHr = "RE.insertHr()"
    
    
    public static func setLineHeight(_ lineHeight: Int) -> String {
        return "RE.setLineHeight('\(lineHeight)px')"
    }
    
    public static func setPlaceholderText(_ newValue: String) -> String {
        return "RE.setPlaceholderText('\(newValue.escaped)')"
    }
    
    public static func setContentEditable(_ value: String) -> String {
        return "RE.editor.contentEditable = \(value)"
    }
    
    public static func setHtml(_ value: String) -> String {
        return "RE.setHtml('\(value.escaped)')"
    }
    
    public static func setFontSize(_ size: Int) -> String {
        return "RE.setFontSize('\(size)px')"
    }
    
    public static func setEditorBackgroundColor(_ color: UIColor) -> String {
        return "RE.setBackgroundColor('\(color.hex)')"
    }
    
    public static func setTextColor(_ color: UIColor) -> String {
        return "RE.setTextColor('\(color.hex)')"
    }
    
    public static func setEditorFontColor(_ color: UIColor)  -> String {
        return "RE.setBaseTextColor('\(color.hex)')"
    }
    
    public static func setTextBackgroundColor(_ color: UIColor) -> String {
        return "RE.setTextBackgroundColor('\(color.hex)')"
    }
    
    public static func header(_ h: Int) -> String {
        return "RE.setHeading('\(h)')"
    }
    
    public static func insertImage(_ url: String, alt: String) -> String {
        return "RE.insertImage('\(url.escaped)', '\(alt.escaped)')"
    }
    
    public static func insertLink(href: String, text: String, title: String = "") -> String {
        return "RE.insertLink('\(href.escaped)', '\(text.escaped)', '\(title.escaped)')"
    }
    
    public static func focus(at: CGPoint)  -> String {
        return "RE.focusAtPoint(\(at.x), \(at.y))"
    }
    
    public static func insertTable(width: Int = 2, height: Int = 2) -> String {
        return "RE.insertTable(\(width), \(height))"
    }
    
    public static func insertHTML(_ jsString: String) -> String {
        return "RE.insertHTML('\(jsString.escaped)')"
    }
}
