public struct PatientData {
    
    public var sex: Sex
    public var age: Int?
    public var height:Double?
    public var weight:Double?
    public var activity:Activity
    public init() {
        sex = Sex.Female;
        activity = Activity.Ambulatory;
    }
}

public enum Sex{
    case Male
    case Female
}

public enum Activity{
    case Ambulatory
    case Wheelchair
    case Immobile
}
