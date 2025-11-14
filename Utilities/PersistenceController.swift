//
//  PersistenceController.swift
//  PortPal
//
//  Core Data persistence management
//

import CoreData
import Foundation

struct PersistenceController {
    // Singleton for use in the app
    static let shared = PersistenceController()

    // Preview instance for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Create sample data for previews
        let sampleTimer = TimerEntity(context: viewContext)
        sampleTimer.id = UUID()
        sampleTimer.ship = "Wonder of the Seas"
        sampleTimer.mmsi = "311001033"
        sampleTimer.port = "CocoCay"
        sampleTimer.berth = "Pier 1"
        sampleTimer.departure = Date().addingTimeInterval(3600 * 4) // 4 hours from now
        sampleTimer.embarkationDate = Date().addingTimeInterval(-86400 * 2) // 2 days ago
        sampleTimer.status = "Docked"
        sampleTimer.createdAt = Date()
        sampleTimer.lastUpdated = Date()

        do {
            try viewContext.save()
        } catch {
            fatalError("Failed to create preview data: \(error)")
        }

        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Create the managed object model programmatically
        let model = NSManagedObjectModel()
        model.entities = [TimerEntity.createEntity()]

        // Create the persistent container with the programmatic model
        container = NSPersistentContainer(name: "PortPal", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        // Enable automatic merging of changes
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Save Context

    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Failed to save context: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // MARK: - Timer Operations

    func createTimer(from portTimer: PortTimer) -> TimerEntity {
        let context = container.viewContext
        let entity = TimerEntity(context: context)

        entity.id = portTimer.id
        entity.ship = portTimer.ship
        entity.mmsi = portTimer.mmsi
        entity.port = portTimer.port
        entity.berth = portTimer.berth
        entity.departure = portTimer.departure
        entity.embarkationDate = portTimer.embarkationDate
        entity.status = portTimer.status
        entity.createdAt = Date()
        entity.lastUpdated = Date()

        // Encode weather data
        if let weatherData = try? JSONEncoder().encode(portTimer.weather) {
            entity.weatherData = weatherData
        }

        // Encode itinerary
        if let itineraryData = try? JSONEncoder().encode(portTimer.itinerary) {
            entity.itineraryData = itineraryData
        }

        save()
        return entity
    }

    func fetchAllTimers() -> [PortTimer] {
        let context = container.viewContext
        let request = TimerEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TimerEntity.departure, ascending: true)]

        do {
            let entities = try context.fetch(request)
            return entities.compactMap { $0.toPortTimer() }
        } catch {
            print("Failed to fetch timers: \(error)")
            return []
        }
    }

    func updateTimer(_ portTimer: PortTimer) {
        let context = container.viewContext
        let request = TimerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", portTimer.id as CVarArg)

        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                entity.ship = portTimer.ship
                entity.mmsi = portTimer.mmsi
                entity.port = portTimer.port
                entity.berth = portTimer.berth
                entity.departure = portTimer.departure
                entity.embarkationDate = portTimer.embarkationDate
                entity.status = portTimer.status
                entity.lastUpdated = Date()

                // Update weather data
                if let weatherData = try? JSONEncoder().encode(portTimer.weather) {
                    entity.weatherData = weatherData
                }

                // Update itinerary
                if let itineraryData = try? JSONEncoder().encode(portTimer.itinerary) {
                    entity.itineraryData = itineraryData
                }

                save()
            }
        } catch {
            print("Failed to update timer: \(error)")
        }
    }

    func deleteTimer(_ portTimer: PortTimer) {
        let context = container.viewContext
        let request = TimerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", portTimer.id as CVarArg)

        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                context.delete(entity)
                save()
            }
        } catch {
            print("Failed to delete timer: \(error)")
        }
    }

    func deleteAllTimers() {
        let context = container.viewContext
        let request = TimerEntity.fetchRequest()

        do {
            let results = try context.fetch(request)
            for entity in results {
                context.delete(entity)
            }
            save()
        } catch {
            print("Failed to delete all timers: \(error)")
        }
    }
}
