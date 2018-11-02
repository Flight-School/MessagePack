import XCTest
@testable import MessagePack

class MessagePackRoundTripTests: XCTestCase {
    var encoder: MessagePackEncoder!
    var decoder: MessagePackDecoder!
    
    override func setUp() {
        self.encoder = MessagePackEncoder()
        self.decoder = MessagePackDecoder()
    }

    func testRoundTrip() {
        let value = Airport.example
        let encoded = try! encoder.encode(value)
        let decoded = try! decoder.decode(Airport.self, from: encoded)
        
        XCTAssertEqual(value.name, decoded.name)
        XCTAssertEqual(value.iata, decoded.iata)
        XCTAssertEqual(value.icao, decoded.icao)
        XCTAssertEqual(value.coordinates[0], decoded.coordinates[0], accuracy: 0.01)
        XCTAssertEqual(value.coordinates[1], decoded.coordinates[1], accuracy: 0.01)
        XCTAssertEqual(value.runways[0].direction, decoded.runways[0].direction)
        XCTAssertEqual(value.runways[0].distance, decoded.runways[0].distance)
        XCTAssertEqual(value.runways[0].surface, decoded.runways[0].surface)
    }
    
    static var allTests = [
        ("testRoundTrip", testRoundTrip)
    ]
}
