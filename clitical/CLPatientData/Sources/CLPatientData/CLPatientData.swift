public struct PatientData {
    
    public var sex: Sex
    public var age: Int?
    public var height:Double?
    public var weight:Double?
    public var activity:Activity
    public var ckd: CKD
    public init() {
        sex = Sex.Female;
        activity = Activity.Ambulatory;
        ckd = CKD.Normal
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

public enum CKD{
    case Normal
    case G3
    case G4
    case G5
    case G5D
}
