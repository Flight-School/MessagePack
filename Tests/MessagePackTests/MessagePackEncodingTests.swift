import XCTest
@testable import MessagePack

class MessagePackEncodingTests: XCTestCase {
    var encoder: MessagePackEncoder!
    
    override func setUp() {
        self.encoder = MessagePackEncoder()
        self.encoder.sortKeys = true
    }
    
    func testEncodeNil() {
        let value = try! encoder.encode(nil as Int?)
        XCTAssertEqual(value, Data(bytes: [0xc0]))
    }
    
    func testEncodeFalse() {
        let value = try! encoder.encode(false)
        XCTAssertEqual(value, Data(bytes: [0xc2]))
    }
    
    func testEncodeTrue() {
        let value = try! encoder.encode(true)
        XCTAssertEqual(value, Data(bytes: [0xc3]))
    }
    
    func testEncodeInt() {
        let value = try! encoder.encode(42 as Int)
        XCTAssertEqual(value, Data(bytes: [0x2A]))
    }
    
    func testEncodeUInt() {
        let value = try! encoder.encode(128 as UInt)
        XCTAssertEqual(value, Data(bytes: [0xCC, 0x80]))
    }
    
    func testEncodeFloat() {
        let value = try! encoder.encode(3.14 as Float)
        XCTAssertEqual(value, Data(bytes: [0xCA, 0x40, 0x48, 0xF5, 0xC3]))
    }
    
    func testEncodeDouble() {
        let value = try! encoder.encode(3.14159 as Double)
        XCTAssertEqual(value, Data(bytes: [0xCB, 0x40, 0x09, 0x21, 0xF9, 0xF0, 0x1B, 0x86, 0x6E]))
    }
    
    func testEncodeString() {
        let value = try! encoder.encode("hello")
        XCTAssertEqual(value, Data(bytes: [0xA5, 0x68, 0x65, 0x6C, 0x6C, 0x6F]))
    }
    
    func testEncodeFixedArray() {
        let value = try! encoder.encode([1, 2, 3])
        XCTAssertEqual(value, Data(bytes: [0x93, 0x01, 0x02, 0x03]))
    }

    func testEncodeVariableArray() {
        let value = try! encoder.encode(Array(1...16))
        XCTAssertEqual(value, Data(bytes: [0xdc] + [0x00, 0x10] + Array(0x01...0x10)))
    }
    
    func testEncodeFixedDictionary() {
        let value = try! encoder.encode(["a": 1, "b": 2])
        XCTAssertEqual(value, Data(bytes: [0x82, 0xA1, 0x61, 0x01, 0xA1, 0x62, 0x02]))
    }

    func testEncodeVariableDictionary() {
        let letters = "abcdefghijklmnopqrstuvwxyz".unicodeScalars
        let dictionary = Dictionary(uniqueKeysWithValues: zip(letters.map { String($0) }, 1...26))
        let value = try! encoder.encode(dictionary)
        XCTAssertEqual(value, Data(bytes: [
            0xDE, 0x0, 0x1A,
            0xA1, 0x61, 0x1,
            0xA1, 0x62, 0x2,
            0xA1, 0x63, 0x3,
            0xA1, 0x64, 0x4,
            0xA1, 0x65, 0x5,
            0xA1, 0x66, 0x6,
            0xA1, 0x67, 0x7,
            0xA1, 0x68, 0x8,
            0xA1, 0x69, 0x9,
            0xA1, 0x6A, 0xA,
            0xA1, 0x6B, 0xB,
            0xA1, 0x6C, 0xC,
            0xA1, 0x6D, 0xD,
            0xA1, 0x6E, 0xE,
            0xA1, 0x6F, 0xF,
            0xA1, 0x70, 0x10,
            0xA1, 0x71, 0x11,
            0xA1, 0x72, 0x12,
            0xA1, 0x73, 0x13,
            0xA1, 0x74, 0x14,
            0xA1, 0x75, 0x15,
            0xA1, 0x76, 0x16,
            0xA1, 0x77, 0x17,
            0xA1, 0x78, 0x18,
            0xA1, 0x79, 0x19,
            0xA1, 0x7A, 0x1A
        ]))
    }
    
    func testEncodeData() {
        let data = "hello".data(using: .utf8)
        let value = try! encoder.encode(data)
        XCTAssertEqual(value, Data(bytes: [0xC4, 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F]))
    }
    
    func testEncodeDate() {
        let date = Date(timeIntervalSince1970: 1)
        let value = try! encoder.encode(date)
        XCTAssertEqual(value, Data(bytes: [0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01]))
    }

    func testEncodeDistantPast() {
        let date = Date.distantPast
        let value = try! encoder.encode(date)
        XCTAssertEqual(value, Data(bytes: [0xC7, 0x0C, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xF1, 0x88, 0x6B, 0x66, 0x00]))
    }

    func testEncodeDistantFuture() {
        let date = Date.distantFuture
        let value = try! encoder.encode(date)
        XCTAssertEqual(value, Data(bytes: [0xC7, 0x0C, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0xEC, 0x31, 0x88, 0x00]))
    }

    func testEncodeArrayWithDate() {
        let date = Date(timeIntervalSince1970: 1)
        let value = try! encoder.encode([date])
        XCTAssertEqual(value, Data(bytes: [0x91, 0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01]))
    }
    
    func testEncodeDictionaryWithDate() {
        let date = Date(timeIntervalSince1970: 1)
        let value = try! encoder.encode(["1": date])
        XCTAssertEqual(value, Data(bytes: [0x81, 0xA1, 0x31, 0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01]))
    }

    static var allTests = [
        ("testEncodeFalse", testEncodeFalse),
        ("testEncodeTrue", testEncodeTrue),
        ("testEncodeInt", testEncodeInt),
        ("testEncodeUInt", testEncodeUInt),
        ("testEncodeFloat", testEncodeFloat),
        ("testEncodeDouble", testEncodeDouble),
        ("testEncodeFixedArray", testEncodeFixedArray),
        ("testEncodeVariableArray", testEncodeVariableArray),
        ("testEncodeFixedDictionary", testEncodeFixedDictionary),
        ("testEncodeVariableDictionary", testEncodeVariableDictionary),
        ("testEncodeDate", testEncodeDate),
        ("testEncodeDistantPast", testEncodeDistantPast),
        ("testEncodeDistantFuture", testEncodeDistantFuture),
        ("testEncodeArrayWithDate", testEncodeArrayWithDate),
        ("testEncodeDictionaryWithDate", testEncodeDictionaryWithDate)
    ]
}
