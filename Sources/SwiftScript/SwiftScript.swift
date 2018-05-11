// 
// STLR Generated Swift File
// 
// Generated: 2018-05-11 07:00:38 +0000
// 
#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#else
import Foundation
#endif
import OysterKit

// 
// SwiftScript Parser
// 
enum SwiftScript : Int, Token {

	// Convenience alias
	private typealias T = SwiftScript

	case _transient = -1, `ows`, `literal`, `stringQuote`, `escapedCharacters`, `escapedCharacter`, `stringCharacter`, `stringBody`, `string`, `hexDigit`, `byte`, `sign`, `integer`, `real`, `red`, `green`, `blue`, `alpha`, `color`, `boolean`, `identifier`, `reference`, `term`, `parameter`, `parameters`, `message`, `sendMessage`, `command`, `script`

	func _rule(_ annotations: RuleAnnotations = [ : ])->Rule {
		switch self {
		case ._transient:
			return CharacterSet(charactersIn: "").terminal(token: T._transient)
		// ows
		case .ows:
			return CharacterSet.whitespaces.terminal(token: T._transient, annotations: annotations).repeated(min: 0, producing: T.ows, annotations: annotations)
		// literal
		case .literal:
			return [
					T.boolean._rule(),
					T.string._rule(),
					T.real._rule(),
					T.integer._rule(),
					T.color._rule(),
					].oneOf(token: T.literal, annotations: annotations)
		// stringQuote
		case .stringQuote:
			return "\"".terminal(token: T.stringQuote, annotations: annotations)
		// escapedCharacters
		case .escapedCharacters:
			return [
					T.stringQuote._rule(),
					"r".terminal(token: T._transient),
					"n".terminal(token: T._transient),
					"t".terminal(token: T._transient),
					"\\".terminal(token: T._transient),
					].oneOf(token: T.escapedCharacters, annotations: annotations)
		// escapedCharacter
		case .escapedCharacter:
			return [
					"\\".terminal(token: T._transient),
					T.escapedCharacters._rule(),
					].sequence(token: T.escapedCharacter, annotations: annotations.isEmpty ? [ : ] : annotations)
		// stringCharacter
		case .stringCharacter:
			return [
					T.escapedCharacter._rule(),
					[
									T.stringQuote._rule(),
									CharacterSet.newlines.terminal(token: T._transient),
									].oneOf(token: T._transient).not(producing: T._transient),
					].oneOf(token: T.stringCharacter, annotations: annotations.isEmpty ? [RuleAnnotation.void : RuleAnnotationValue.set] : annotations)
		// stringBody
		case .stringBody:
			return T.stringCharacter._rule([RuleAnnotation.void : RuleAnnotationValue.set]).repeated(min: 0, producing: T.stringBody, annotations: annotations)
		// string
		case .string:
			return [
					T.stringQuote._rule([RuleAnnotation.transient : RuleAnnotationValue.set]),
					T.stringBody._rule(),
					T.stringQuote._rule([RuleAnnotation.error : RuleAnnotationValue.string("Missing terminating quote"),RuleAnnotation.transient : RuleAnnotationValue.set]),
					].sequence(token: T.string, annotations: annotations.isEmpty ? [ : ] : annotations)
		// hexDigit
		case .hexDigit:
			return [
					CharacterSet.decimalDigits.terminal(token: T._transient),
					"A".terminal(token: T._transient),
					"B".terminal(token: T._transient),
					"C".terminal(token: T._transient),
					"D".terminal(token: T._transient),
					"E".terminal(token: T._transient),
					"F".terminal(token: T._transient),
					"a".terminal(token: T._transient),
					"b".terminal(token: T._transient),
					"c".terminal(token: T._transient),
					"d".terminal(token: T._transient),
					"e".terminal(token: T._transient),
					"f".terminal(token: T._transient),
					].oneOf(token: T.hexDigit, annotations: annotations.isEmpty ? [RuleAnnotation.transient : RuleAnnotationValue.set] : annotations)
		// byte
		case .byte:
			return [
					T.hexDigit._rule([RuleAnnotation.transient : RuleAnnotationValue.set]),
					T.hexDigit._rule([RuleAnnotation.transient : RuleAnnotationValue.set]),
					].sequence(token: T.byte, annotations: annotations.isEmpty ? [ : ] : annotations)
		// sign
		case .sign:
			return ScannerRule.oneOf(token: T.sign, ["+", "-"],[ : ].merge(with: annotations))
		// integer
		case .integer:
			return [
					T.sign._rule().optional(producing: T._transient),
					CharacterSet.decimalDigits.terminal(token: T._transient).repeated(min: 1, producing: T._transient),
					].sequence(token: T.integer, annotations: annotations.isEmpty ? [ : ] : annotations)
		// real
		case .real:
			return [
					T.sign._rule().optional(producing: T._transient),
					CharacterSet.decimalDigits.terminal(token: T._transient).repeated(min: 1, producing: T._transient),
					".".terminal(token: T._transient),
					CharacterSet.decimalDigits.terminal(token: T._transient).repeated(min: 1, producing: T._transient),
					].sequence(token: T.real, annotations: annotations.isEmpty ? [ : ] : annotations)
		// red
		case .red:
			return [T.byte._rule()].sequence(token: self)
		// green
		case .green:
			return [T.byte._rule()].sequence(token: self)
		// blue
		case .blue:
			return [T.byte._rule()].sequence(token: self)
		// alpha
		case .alpha:
			return T.byte._rule().optional(producing: T.alpha, annotations: annotations)
		// color
		case .color:
			return [
					"#".terminal(token: T._transient),
					T.red._rule(),
					T.green._rule(),
					T.blue._rule(),
					T.alpha._rule(),
					].sequence(token: T.color, annotations: annotations.isEmpty ? [ : ] : annotations)
		// boolean
		case .boolean:
			return ScannerRule.oneOf(token: T.boolean, ["true", "false"],[ : ].merge(with: annotations))
		// identifier
		case .identifier:
			return [
					CharacterSet.letters.terminal(token: T._transient),
					[
									CharacterSet.letters.terminal(token: T._transient),
									CharacterSet.decimalDigits.terminal(token: T._transient),
									].oneOf(token: T._transient).repeated(min: 0, producing: T._transient),
					].sequence(token: T.identifier, annotations: annotations.isEmpty ? [ : ] : annotations)
		// reference
		case .reference:
			return [
					T.identifier._rule(),
					"(".terminal(token: T._transient).not(producing: T._transient).lookahead(),
					[
									".".terminal(token: T._transient),
									T.identifier._rule(),
									"(".terminal(token: T._transient).not(producing: T._transient).lookahead(),
									].sequence(token: T._transient).repeated(min: 0, producing: T._transient),
					].sequence(token: T.reference, annotations: annotations.isEmpty ? [ : ] : annotations)
		// term
		case .term:
			return [
					T.literal._rule(),
					T.reference._rule(),
					].oneOf(token: T.term, annotations: annotations)
		// parameter
		case .parameter:
			return [
					T.identifier._rule(),
					T.ows._rule([RuleAnnotation.transient : RuleAnnotationValue.set]),
					":".terminal(token: T._transient),
					T.ows._rule([RuleAnnotation.transient : RuleAnnotationValue.set]),
					T.term._rule(),
					].sequence(token: T.parameter, annotations: annotations.isEmpty ? [ : ] : annotations)
		// parameters
		case .parameters:
			return [
					T.parameter._rule(),
					[
									T.ows._rule([RuleAnnotation.transient : RuleAnnotationValue.set]),
									",".terminal(token: T._transient),
									T.ows._rule([RuleAnnotation.transient : RuleAnnotationValue.set]),
									T.parameter._rule(),
									].sequence(token: T._transient).repeated(min: 0, producing: T._transient),
					].sequence(token: T.parameters, annotations: annotations.isEmpty ? [ : ] : annotations)
		// message
		case .message:
			return [T.identifier._rule([RuleAnnotation.transient : RuleAnnotationValue.set])].sequence(token: self)
		// sendMessage
		case .sendMessage:
			return [
					[
									T.reference._rule(),
									".".terminal(token: T._transient),
									].sequence(token: T._transient).optional(producing: T._transient),
					T.message._rule([RuleAnnotation.error : RuleAnnotationValue.string("Expected message's name")]),
					"(".terminal(token: T._transient, annotations: [RuleAnnotation.error : RuleAnnotationValue.string("Expected ( at start of message send")]),
					T.ows._rule([RuleAnnotation.transient : RuleAnnotationValue.set]),
					T.parameters._rule().optional(producing: T._transient),
					T.ows._rule([RuleAnnotation.transient : RuleAnnotationValue.set]),
					")".terminal(token: T._transient),
					].sequence(token: T.sendMessage, annotations: annotations.isEmpty ? [ : ] : annotations)
		// command
		case .command:
			return [T.sendMessage._rule()].sequence(token: self)
		// script
		case .script:
			return [
					T.command._rule(),
					[
									CharacterSet.newlines.terminal(token: T._transient).repeated(min: 1, producing: T._transient),
									T.command._rule(),
									].sequence(token: T._transient).repeated(min: 0, producing: T._transient),
					].sequence(token: T.script, annotations: annotations.isEmpty ? [ : ] : annotations)
		}
	}


	// Create a language that can be used for parsing etc
	public static var generatedLanguage : Parser {
		return Parser(grammar: [T.script._rule()])
	}

	// Convient way to apply your grammar to a string
	public static func parse(source: String) throws -> HomogenousTree {
		return try AbstractSyntaxTreeConstructor().build(source, using: generatedLanguage)
	}
}
