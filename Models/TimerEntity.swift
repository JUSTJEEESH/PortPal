//
//  TimerEntity.swift
//  PortPal
//
//  Core Data entity for persisting PortTimer data
//

import Foundation
import CoreData

@objc(TimerEntity)
public class TimerEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var ship: String
    @NSManaged public var mmsi: String
    @NSManaged public var port: String
    @NSManaged public var berth: String
    @NSManaged public var departure: Date
    @NSManaged public var embarkationDate: Date
    @NSManaged public var status: String
    @NSManaged public var weatherData: Data?
    @NSManaged public var itineraryData: Data?
    @NSManaged public var createdAt: Date
    @NSManaged public var lastUpdated: Date
}

extension TimerEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimerEntity> {
        return NSFetchRequest<TimerEntity>(entityName: "TimerEntity")
    }

    // Convert TimerEntity to PortTimer
    func toPortTimer() -> PortTimer? {
        var weather = WeatherData(temp: 82, condition: "Sunny", icon: "sun.max.fill")
        var itinerary: [PortStop] = []

        // Decode weather data
        if let weatherData = weatherData,
           let decodedWeather = try? JSONDecoder().decode(WeatherData.self, from: weatherData) {
            weather = decodedWeather
        }

        // Decode itinerary data
        if let itineraryData = itineraryData,
           let decodedItinerary = try? JSONDecoder().decode([PortStop].self, from: itineraryData) {
            itinerary = decodedItinerary
        }

        return PortTimer(
            id: id,
            ship: ship,
            mmsi: mmsi,
            port: port,
            berth: berth,
            departure: departure,
            embarkationDate: embarkationDate,
            status: status,
            weather: weather,
            itinerary: itinerary
        )
    }
}

// MARK: - Core Data Model Definition

extension TimerEntity {
    static func createEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "TimerEntity"
        entity.managedObjectClassName = NSStringFromClass(TimerEntity.self)

        // Define attributes
        var properties: [NSAttributeDescription] = []

        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false
        properties.append(idAttr)

        let shipAttr = NSAttributeDescription()
        shipAttr.name = "ship"
        shipAttr.attributeType = .stringAttributeType
        shipAttr.isOptional = false
        properties.append(shipAttr)

        let mmsiAttr = NSAttributeDescription()
        mmsiAttr.name = "mmsi"
        mmsiAttr.attributeType = .stringAttributeType
        mmsiAttr.isOptional = false
        properties.append(mmsiAttr)

        let portAttr = NSAttributeDescription()
        portAttr.name = "port"
        portAttr.attributeType = .stringAttributeType
        portAttr.isOptional = false
        properties.append(portAttr)

        let berthAttr = NSAttributeDescription()
        berthAttr.name = "berth"
        berthAttr.attributeType = .stringAttributeType
        berthAttr.isOptional = false
        properties.append(berthAttr)

        let departureAttr = NSAttributeDescription()
        departureAttr.name = "departure"
        departureAttr.attributeType = .dateAttributeType
        departureAttr.isOptional = false
        properties.append(departureAttr)

        let embarkationAttr = NSAttributeDescription()
        embarkationAttr.name = "embarkationDate"
        embarkationAttr.attributeType = .dateAttributeType
        embarkationAttr.isOptional = false
        properties.append(embarkationAttr)

        let statusAttr = NSAttributeDescription()
        statusAttr.name = "status"
        statusAttr.attributeType = .stringAttributeType
        statusAttr.isOptional = false
        properties.append(statusAttr)

        let weatherDataAttr = NSAttributeDescription()
        weatherDataAttr.name = "weatherData"
        weatherDataAttr.attributeType = .binaryDataAttributeType
        weatherDataAttr.isOptional = true
        properties.append(weatherDataAttr)

        let itineraryDataAttr = NSAttributeDescription()
        itineraryDataAttr.name = "itineraryData"
        itineraryDataAttr.attributeType = .binaryDataAttributeType
        itineraryDataAttr.isOptional = true
        properties.append(itineraryDataAttr)

        let createdAtAttr = NSAttributeDescription()
        createdAtAttr.name = "createdAt"
        createdAtAttr.attributeType = .dateAttributeType
        createdAtAttr.isOptional = false
        properties.append(createdAtAttr)

        let lastUpdatedAttr = NSAttributeDescription()
        lastUpdatedAttr.name = "lastUpdated"
        lastUpdatedAttr.attributeType = .dateAttributeType
        lastUpdatedAttr.isOptional = false
        properties.append(lastUpdatedAttr)

        entity.properties = properties

        return entity
    }
}
