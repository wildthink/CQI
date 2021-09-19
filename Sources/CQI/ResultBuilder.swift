//
//  File.swift
//  
//
//  Created by Jason Jobe on 9/19/21.
//
import Foundation

// https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md#virtualized-abstract-syntax-trees-asts

public indirect enum ResultBuilderTerm<Expression> {
    case expression(Expression)
    case lambda(() -> Expression)
    case block([ResultBuilderTerm])
    case cond(ResultBuilderTerm)
    case optional(ResultBuilderTerm?)
}

public protocol ResultBuilder {
    associatedtype Expression
    typealias Component = ResultBuilderTerm<Expression>
    static func buildFinalResult(_ component: Component) -> Component
}

public protocol ReducingResultBuilder: ResultBuilder {
    static func buildFinalResult(_ component: Component) -> Expression
}

public extension ResultBuilder {
    static func buildExpression(_ expression: Expression) -> Component { .expression(expression) }
    static func buildBlock(_ components: Component...) -> Component { .block(components) }
    static func buildArray(_ components: [Component]) -> Component { .block(components) }
    static func buildLimitedAvailability(_ component: Component) -> Component { component }
    
    static func buildEither(first component: Component) -> Component { .cond(component) }
    static func buildEither(second component: Component) -> Component { .cond(component) }
    static func buildOptional(_ component: Component?) -> Component { .optional(component) }
    static func buildFinalResult(_ component: Component) -> Component { component }
}

public extension ResultBuilder {
    
    static func buildResultArray (_ component: Component) -> [Expression] {
        switch component {
            case .expression(let e): return [e]
            case .lambda(let fn): return [fn()]
            case .block(let children): return children.flatMap(buildResultArray)
            case .cond(let choice): return buildResultArray(choice)
            case .optional(let child?): return buildResultArray(child)
            case .optional(nil): return []
        }
    }
}

@resultBuilder
public enum StringBuilder: ReducingResultBuilder {
    public typealias Expression = String
    
    public static func buildFinalResult(_ component: Component) -> String {
        buildResultArray(component).joined(separator: "\n")
    }
}

public extension StringBuilder {
    
    static func buildExpression(_ expression: Int) -> Component {
        .expression("\(expression)")
    }
    static func buildExpression(_ expression: Component) -> Component {
        expression
    }
    static func buildFinalResult(_ component: Component) -> [String] {
        buildResultArray(component)
    }
    
}
