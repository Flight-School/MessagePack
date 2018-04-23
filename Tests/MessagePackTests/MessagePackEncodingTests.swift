import XCTest
@testable import MessagePack

class MessagePackTests: XCTestCase {
    var encoder: MessagePackEncoder = MessagePackEncoder()
    
    func testEncodeFalse() {
        let value = try! encoder.encode(false)
        XCTAssertEqual(value, Data(bytes: [0xc2]))
    }
    
    func testEncodeTrue() {
        let value = try! encoder.encode(true)
        XCTAssertEqual(value, Data(bytes: [0xc3]))
    }
    
    func testEncodeInt() {
        let value = try! encoder.encode(42)
        XCTAssertEqual(value, Data(bytes: [0x2A]))
    }
    
    func testEncodeDouble() {
        let value = try! encoder.encode(3.14159)
        XCTAssertEqual(value, Data(bytes: [0xCB, 0x40, 0x09, 0x21, 0xF9, 0xF0, 0x1B, 0x86, 0x6E]))
    }
    
    func testEncodeArray() {
        let value = try! encoder.encode([1, 2, 3])
        XCTAssertEqual(value, Data(bytes: [0x93, 0x01, 0x02, 0x03]))
    }
    
    func testEncodeDictionary() {
        let value = try! encoder.encode(["a": 1, "b": 2, "c": 3])
        XCTAssertEqual(value, Data(bytes: [0x83, 0xA1, 0x62, 0x02, 0xA1, 0x61, 0x01, 0xA1, 0x63, 0x03]))
    }

    static var allTests = [
        ("testEncodeFalse", testEncodeFalse),
        ("testEncodeTrue", testEncodeTrue),
        ("testEncodeInt", testEncodeInt),
        ("testEncodeDouble", testEncodeDouble),
        ("testEncodeArray", testEncodeArray),
        ("testEncodeDictionary", testEncodeDictionary)
    ]
}
