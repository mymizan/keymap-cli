import XCTest
@testable import keymap

final class ErrorHandlerTests: XCTestCase {
    
    // MARK: - Manager Error Handling
    
    func testHandleShortcutAlreadyExists() {
        let error = ReplacementManagerError.shortcutAlreadyExists("test")
        let message = ErrorHandler.buildErrorMessage(error, context: "")
        XCTAssertTrue(message.contains("already exists"))
        XCTAssertTrue(message.contains("keymap update"))
    }
    
    func testHandleShortcutNotFound() {
        let error = ReplacementManagerError.shortcutNotFound("test")
        let message = ErrorHandler.buildErrorMessage(error, context: "")
        XCTAssertTrue(message.contains("not found"))
        XCTAssertTrue(message.contains("keymap list"))
    }
    
    func testHandleEmptyShortcut() {
        let error = ReplacementManagerError.emptyShortcut
        let message = ErrorHandler.buildErrorMessage(error, context: "")
        XCTAssertTrue(message.contains("empty"))
        XCTAssertTrue(message.contains("Hint"))
    }
    
    func testHandleEmptyExpansion() {
        let error = ReplacementManagerError.emptyExpansion
        let message = ErrorHandler.buildErrorMessage(error, context: "")
        XCTAssertTrue(message.contains("empty"))
        XCTAssertTrue(message.contains("Hint"))
    }
    
    // MARK: - Writer Error Handling
    
    func testHandleWriterFileNotFound() {
        let error = PlistWriterError.fileNotFound
        let message = ErrorHandler.buildErrorMessage(error, context: "")
        XCTAssertTrue(message.contains("GlobalPreferences.plist"))
    }
    
    func testHandleWriterCannotCreateBackup() {
        let error = PlistWriterError.cannotCreateBackup
        let message = ErrorHandler.buildErrorMessage(error, context: "")
        XCTAssertTrue(message.contains("disk space") || message.contains("Hint"))
    }
    
    func testHandleWriterSerializationFailed() {
        let error = PlistWriterError.serializationFailed
        let message = ErrorHandler.buildErrorMessage(error, context: "")
        XCTAssertTrue(message.contains("keymap list"))
    }
    
    func testHandleWriterWriteFailure() {
        let error = PlistWriterError.writeFailure("test failure")
        let message = ErrorHandler.buildErrorMessage(error, context: "")
        XCTAssertTrue(message.contains("test failure"))
    }
    
    // MARK: - Reader Error Handling
    
    func testHandleReaderFileNotFound() {
        let error = PlistReaderError.fileNotFound
        let message = ErrorHandler.buildErrorMessage(error, context: "")
        XCTAssertTrue(message.contains("System Settings"))
    }
    
    func testHandleReaderInvalidFormat() {
        let error = PlistReaderError.invalidFormat
        let message = ErrorHandler.buildErrorMessage(error, context: "")
        XCTAssertTrue(message.contains("Hint"))
    }
    
    func testHandleReaderDecodingError() {
        let error = PlistReaderError.decodingError("test error")
        let message = ErrorHandler.buildErrorMessage(error, context: "")
        XCTAssertTrue(message.contains("corrupted"))
    }
    
    // MARK: - Error with Context
    
    func testErrorMessageWithContext() {
        let error = ReplacementManagerError.shortcutNotFound("test")
        let message = ErrorHandler.buildErrorMessage(error, context: "list operation")
        XCTAssertTrue(message.contains("list operation"))
        XCTAssertTrue(message.contains("not found"))
    }
    
    // MARK: - Input Validation
    
    func testValidateEmptyShortcut() {
        XCTAssertFalse(ErrorHandler.validateInput(shortcut: ""))
    }
    
    func testValidateValidShortcut() {
        XCTAssertTrue(ErrorHandler.validateInput(shortcut: "test"))
    }
    
    func testValidateValidShortcutAndExpansion() {
        XCTAssertTrue(ErrorHandler.validateInput(shortcut: "test", expansion: "expansion"))
    }
    
    func testValidateEmptyExpansion() {
        XCTAssertFalse(ErrorHandler.validateInput(shortcut: "test", expansion: ""))
    }
    
    func testValidateWhitespaceOnlyShortcut() {
        XCTAssertFalse(ErrorHandler.validateInput(shortcut: "   "))
    }
    
    func testValidateWhitespaceShortcut() {
        XCTAssertTrue(ErrorHandler.validateInput(shortcut: "  test  "))
    }
    
    // MARK: - Helper
    
    // Removed captureErrorMessage as it's not needed with buildErrorMessage
}
