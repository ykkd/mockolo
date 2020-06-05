//
//  Copyright (c) 2018. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

extension Int {
    var tab: String {
        return String(repeating: "    ", count: self)
    }
}

extension String {
    enum SwiftKeywords: String {
        case `throws` = "throws"
        case `rethrows` = "rethrows"
        case `try` = "try"
        case `for` = "for"
        case `in` = "in"
        case `where` = "where"
        case `while` = "while"
        case `default` = "default"
        case `fallthrough` = "fallthrough"
        case `do` = "do"
        case `switch` = "switch"
    }
    static public let protocolDecl = "protocol ".data(using: .utf8)
    static public let classDecl = "class ".data(using: .utf8)

    static let `inout` = "inout"
    static let hasBlankInit = "_hasBlankInit"
    static let `static` = "static"
    static let importSpace = "import "
    static public let `class` = "class"
    static public let `final` = "final"
    static let override = "override"
    static let mockType = "protocol"
    static let unknownVal = "Unknown"
    static let prefix = "prefix"
    static let any = "Any"
    static let anyObject = "AnyObject"
    static let fatalError = "fatalError"
    static let available = "available"
    static let `public` = "public"
    static let `open` = "open"
    static let initializer = "init"
    static let argsHistorySuffix = "Values"
    static let handlerSuffix = "Handler"
    static let observable = "Observable"
    static let rxObservable = "RxSwift.Observable"
    static let observableLeftAngleBracket = observable + "<"
    static let rxObservableLeftAngleBracket = rxObservable + "<"
    static let publishSubject = "PublishSubject"
    static let behaviorSubject = "BehaviorSubject"
    static let replaySubject = "ReplaySubject"
    static let replaySubjectCreate = ".create(bufferSize: 1)"
    static let behaviorRelay = "BehaviorRelay"
    static let variable = "Variable"
    static let empty = ".empty()"
    static let observableEmpty = "Observable.empty()"
    static let rxObservableEmpty = "RxSwift.Observable.empty()"
    static let `required` = "required"
    static let `convenience` = "convenience"
    static let closureArrow = "->"
    static let moduleColon = "module:"
    static let typealiasColon = "typealias:"
    static let rxColon = "rx:"
    static let varColon = "var:"
    static let historyColon = "history:"
    static let `typealias` = "typealias"
    static let annotationArgDelimiter = ";"
    static let subjectSuffix = "Subject"
    static let underlyingVarPrefix = "_"
    static let setCallCountSuffix = "SetCallCount"
    static let callCountSuffix = "CallCount"
    static let initializerLeftParen = "init("
    static let `escaping` = "@escaping"
    static let autoclosure = "@autoclosure"
    static public let mockAnnotation = "@mockable"
    static public let mockObservable = "@MockObservable"
    static public let poundIf = "#if "
    static public let poundEndIf = "#endif"
    static public let headerDoc =
    """
    ///
    /// @Generated by Mockolo
    ///
    """


    var isThrowsOrRethrows: Bool {
        return self == SwiftKeywords.throws.rawValue || self == SwiftKeywords.rethrows.rawValue
    }

    var safeName: String {
        if let _ = SwiftKeywords(rawValue: self) {
            return "`\(self)`"
        }
        return self
    }

    var withSpace: String {
        return "\(self) "
    }

    var withLeftAngleBracket: String {
        return "\(self)<"
    }
    
    var withRightAngleBracket: String {
        return "\(self)>"
    }
    
    var withColon: String {
        return "\(self):"
    }

    var withLeftParen: String {
        return "\(self)("
    }

    var withRightParen: String {
        return "\(self))"
    }
    

    func canBeInitParam(type: String, isStatic: Bool) -> Bool {
        return !(isStatic || type == .unknownVal || (type.hasSuffix("?") && type.contains(String.closureArrow)) ||  isGenerated(type: Type(type)))
    }
    
    func isGenerated(type: Type) -> Bool {
          return self.hasPrefix(.underlyingVarPrefix) ||
              self.hasSuffix(.setCallCountSuffix) ||
              self.hasSuffix(.callCountSuffix) ||
              self.hasSuffix(.subjectSuffix) ||
              (self.hasSuffix(.handlerSuffix) && type.isOptional)
    }
    
    func arguments(with delimiter: String) -> [String: String]? {
        let argstr = self
        let args = argstr.components(separatedBy: delimiter)
        var argsMap = [String: String]()
        for item in args {
            let keyVal = item.components(separatedBy: "=").map{$0.trimmingCharacters(in: .whitespaces)}
            
            if let k = keyVal.first {
                if k.contains(":") {
                    break
                }
                
                if let v = keyVal.last {
                    argsMap[k] = v
                }
            }
        }
        return !argsMap.isEmpty ? argsMap : nil
    }
}

let separatorsForDisplay = CharacterSet(charactersIn: "<>[] :,()_-.&@#!{}@+\"\'")
let separatorsForLiterals = CharacterSet(charactersIn: "?<>[] :,()_-.&@#!{}@+\"\'")

extension StringProtocol {
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    var capitlizeFirstLetter: String {
        return prefix(1).capitalized + dropFirst()
    }
    
    func shouldParse(with exclusionList: [String]? = nil) -> Bool {
        guard hasSuffix(".swift") else { return false }
        guard let exlist = exclusionList else { return true }
        
        if let name = components(separatedBy: ".swift").first {
            for ex in exlist {
                if name.hasSuffix(ex) {
                    return false
                }
            }
            return true
        }
        
        return false
    }

    var literalComponents: [String] {
        return self.components(separatedBy: separatorsForLiterals)
    }

    var displayableComponents: [String] {
        let ret = self.replacingOccurrences(of: "?", with: "Optional")
        return ret.components(separatedBy: separatorsForDisplay).filter {!$0.isEmpty}
    }

    var components: [String] {
        return self.components(separatedBy: separatorsForDisplay).filter {!$0.isEmpty}
    }

    var asTestableImport: String {
        return "@testable \(self.asImport)"
    }

    var asImport: String {
        return "import \(self)"
    }
    
    var moduleNameInImport: String {
        guard self.hasPrefix(String.importSpace) else { return "" }
        return self.dropFirst(String.importSpace.count).trimmingCharacters(in: .whitespaces)
    }
}
