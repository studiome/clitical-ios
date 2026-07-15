public struct PatientData {
    public var sex: Sex = .female
    public var age: Int?
    public var height: Double? //cm
    public var weight: Double? //kg
    public var alb: Double?
    public var activity: Activity = .ambulatory
    public var hasCHF = false
    public var hasCAD = false
    public var hasCVD = false
    public var ckd: CKD = .normal
    public var malignantNeoplasm: MalignantNeoplasm = .no
    public var hasAILesion = false
    public var hasFPLesion = false
    public var hasBKLesion = false
    public var isUrgent = false
    public var hasFever = false
    public var hasAbnormalWBC = false
    public var hasLocalInfection = false
    public var hasDyslipidemia = false
    public var isSmoking = false
    public var hasContraLateralLesion = false
    public var hasOtherVD = false
    public var rutherford: RutherfordClassification = .class4

    public init() {}

    public mutating func clear() {
        self = PatientData()
    }
}

public enum Sex: CaseIterable{
    case male
    case female
}

public enum Activity: CaseIterable{
    case ambulatory
    case wheelchair
    case immobile
}

public enum CKD: CaseIterable{
    case normal
    case g3
    case g4
    case g5
    case g5D
}

public enum MalignantNeoplasm: CaseIterable{
    case no
    case pastHistory
    case underTreatment
}

public enum RutherfordClassification: CaseIterable{
    case class4
    case class5
    case class6
}
