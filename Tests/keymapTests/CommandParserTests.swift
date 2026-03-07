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

    // MARK: - Extended Command Parsing Tests
    
    func testParseExportCommand() {
        let args1 = ["keymap", "export"]
        let cmd1 = CommandParser.parse(arguments: args1)
        if case .export(let file) = cmd1 {
            XCTAssertNil(file)
        } else {
            XCTFail("Expected export command without path")
        }

        let args2 = ["keymap", "export", "out.json"]
        let cmd2 = CommandParser.parse(arguments: args2)
        if case .export(let file) = cmd2 {
            XCTAssertEqual(file, "out.json")
        } else {
            XCTFail("Expected export command with file path")
        }

        let args3 = ["keymap", "export", "a", "b"]
        let cmd3 = CommandParser.parse(arguments: args3)
        if case .unknown = cmd3 {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected unknown for too many export args")
        }
    }
    
    func testParseImportCommand() {
        let args = ["keymap", "import", "in.json"]
        let command = CommandParser.parse(arguments: args)
        if case .import(let file) = command {
            XCTAssertEqual(file, "in.json")
        } else {
            XCTFail("Expected import command")
        }
        
        let bad = ["keymap", "import"]
        let cmd2 = CommandParser.parse(arguments: bad)
        if case .unknown = cmd2 {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected unknown for missing import file")
        }
    }
    
    func testParseSearchCommand() {
        let args = ["keymap", "search", "term"]
        let command = CommandParser.parse(arguments: args)
        if case .search(let query) = command {
            XCTAssertEqual(query, "term")
        } else {
            XCTFail("Expected search command")
        }
        
        let bad = ["keymap", "search"]
        let cmd2 = CommandParser.parse(arguments: bad)
        if case .unknown = cmd2 {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected unknown for missing search term")
        }
    }
    
    func testParseEnableDisableCommands() {
        let en = ["keymap", "enable", "foo"]
        let cmdE = CommandParser.parse(arguments: en)
        if case .enable(let s) = cmdE {
            XCTAssertEqual(s, "foo")
        } else {
            XCTFail("Expected enable command")
        }
        
        let dis = ["keymap", "disable", "foo"]
        let cmdD = CommandParser.parse(arguments: dis)
        if case .disable(let s) = cmdD {
            XCTAssertEqual(s, "foo")
        } else {
            XCTFail("Expected disable command")
        }
        
        let bad = ["keymap", "enable"]
        let cmd3 = CommandParser.parse(arguments: bad)
        if case .unknown = cmd3 {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected unknown for missing enable shortcut")
        }
    }

}