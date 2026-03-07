import XCTest
@testable import keymap

final class CommandParserTests: XCTestCase {

    func testParseAddCommand() {
        let args = ["keymap", "add", "x.oc", "npm install v24.14.0"]
        let command = CommandParser.parse(arguments: args)
        
        if case .add(let shortcut, let expansion) = command {
            XCTAssertEqual(shortcut, "x.oc")
            XCTAssertEqual(expansion, "npm install v24.14.0")
        } else {
            XCTFail("Expected add command")
        }
    }
    
    func testParseAddCommandMissingExpansion() {
        let args = ["keymap", "add", "x.oc"]
        let command = CommandParser.parse(arguments: args)
        
        if case .unknown = command {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected unknown command for missing arguments")
        }
    }
    
    func testParseRemoveCommand() {
        let args = ["keymap", "remove", "x.oc"]
        let command = CommandParser.parse(arguments: args)
        
        if case .remove(let shortcut) = command {
            XCTAssertEqual(shortcut, "x.oc")
        } else {
            XCTFail("Expected remove command")
        }
    }
    
    func testParseRemoveCommandMissingShortcut() {
        let args = ["keymap", "remove"]
        let command = CommandParser.parse(arguments: args)
        
        if case .unknown = command {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected unknown command for missing arguments")
        }
    }
    
    func testParseUpdateCommand() {
        let args = ["keymap", "update", "x.oc", "npm install v24.15.0"]
        let command = CommandParser.parse(arguments: args)
        
        if case .update(let shortcut, let expansion) = command {
            XCTAssertEqual(shortcut, "x.oc")
            XCTAssertEqual(expansion, "npm install v24.15.0")
        } else {
            XCTFail("Expected update command")
        }
    }
    
    func testParseUpdateCommandMissingArguments() {
        let args = ["keymap", "update", "x.oc"]
        let command = CommandParser.parse(arguments: args)
        
        if case .unknown = command {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected unknown command for missing arguments")
        }
    }
    
    func testParseListCommand() {
        let args = ["keymap", "list"]
        let command = CommandParser.parse(arguments: args)
        
        if case .list = command {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected list command")
        }
    }
    
    func testParseHelpCommand() {
        let args = ["keymap", "help"]
        let command = CommandParser.parse(arguments: args)
        
        if case .help = command {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected help command")
        }
    }
    
    func testParseHelpWithShortFlag() {
        let args = ["keymap", "-h"]
        let command = CommandParser.parse(arguments: args)
        
        if case .help = command {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected help command")
        }
    }
    
    func testParseHelpWithLongFlag() {
        let args = ["keymap", "--help"]
        let command = CommandParser.parse(arguments: args)
        
        if case .help = command {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected help command")
        }
    }
    
    func testParseUnknownCommand() {
        let args = ["keymap", "invalid"]
        let command = CommandParser.parse(arguments: args)
        
        if case .unknown = command {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected unknown command")
        }
    }
    
    func testParseEmptyArguments() {
        let args = ["keymap"]
        let command = CommandParser.parse(arguments: args)
        
        if case .help = command {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected help command for empty arguments")
        }
    }
    
    func testParseCaseInsensitive() {
        let args = ["keymap", "ADD", "x.oc", "npm install"]
        let command = CommandParser.parse(arguments: args)
        
        if case .add(let shortcut, let expansion) = command {
            XCTAssertEqual(shortcut, "x.oc")
            XCTAssertEqual(expansion, "npm install")
        } else {
            XCTFail("Expected add command (case insensitive)")
        }
    }
    
    func testAddWithComplexExpansion() {
        let args = ["keymap", "add", "gh.pam", "git pull && git status"]
        let command = CommandParser.parse(arguments: args)
        
        if case .add(let shortcut, let expansion) = command {
            XCTAssertEqual(shortcut, "gh.pam")
            XCTAssertEqual(expansion, "git pull && git status")
        } else {
            XCTFail("Expected add command with complex expansion")
        }
    }

}