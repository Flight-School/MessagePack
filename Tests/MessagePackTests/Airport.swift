struct Airport: Codable, Equatable {
    let name: String
    let iata: String
    let icao: String
    let coordinates: [Double]
    
    struct Runway: Codable, Equatable {
        enum Surface: String, Codable, Equatable {
            case rigid, flexible, gravel, sealed, unpaved, other
        }
        
        let direction: String
        let distance: Int
        let surface: Surface
    }
    
    let runways: [Runway]
    
    static var example: Airport {
        return Airport(
            name: "Portland International Airport",
            iata: "PDX",
            icao: "KPDX",
            coordinates: [-122.5975,
                          45.5886111111111],
            runways: [
                Airport.Runway(
                    direction: "3/21",
                    distance: 1829,
                    surface: .flexible
                )
            ]
        )
    }
}
