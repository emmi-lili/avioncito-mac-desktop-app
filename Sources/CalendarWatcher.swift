import EventKit

/// Lee los eventos de la app Calendario de macOS (incluye tu cuenta de Google si está agregada ahí).
final class CalendarWatcher {
    let store = EKEventStore()

    func requestAccess(_ completion: @escaping (Bool) -> Void) {
        let done: (Bool, Error?) -> Void = { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
        if #available(macOS 14.0, *) {
            store.requestFullAccessToEvents(completion: done)
        } else {
            store.requestAccess(to: .event, completion: done)
        }
    }

    /// Eventos que empiezan entre "hace 1 minuto" y "dentro de `seconds` segundos".
    func upcomingEvents(within seconds: TimeInterval) -> [EKEvent] {
        let now = Date()
        let predicate = store.predicateForEvents(
            withStart: now.addingTimeInterval(-60),
            end: now.addingTimeInterval(seconds),
            calendars: nil
        )
        return store.events(matching: predicate)
            .filter { !$0.isAllDay && !isDeclined($0) }
            .sorted { $0.startDate < $1.startDate }
    }

    /// Ignora reuniones que rechazaste.
    private func isDeclined(_ event: EKEvent) -> Bool {
        event.attendees?.first(where: { $0.isCurrentUser })?.participantStatus == .declined
    }
}
