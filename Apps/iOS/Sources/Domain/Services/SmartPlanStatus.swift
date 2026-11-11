/// Coverage and time are independent: a shorter plan requires explicit acceptance.
nonisolated enum SmartPlanStatus: Sendable {
    case complete
    case shorter
    case unavailable
}
