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

public enum Sex:String{
    case Male = "Male"
    case Female = "Female"
}

public enum Activity{
    case Ambulatory
    case Wheelchair
    case Immobile
}
