public struct PatientData: Equatable, Sendable {
    /// No default: sex is a covariate of every prediction, so leaving it
    /// unanswered has to be distinguishable from a deliberate answer.
    public var sex: Sex?
    public var age: Int?
    /// Height in centimetres.
    public var height: Double?
    /// Weight in kilograms.
    public var weight: Double?
    /// Serum albumin in g/dL.
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

public enum Sex: CaseIterable, Hashable, Sendable {
    case male
    case female
}

public enum Activity: CaseIterable, Hashable, Sendable {
    case ambulatory
    case wheelchair
    case immobile
}

public enum CKD: CaseIterable, Hashable, Sendable {
    case normal
    case g3
    case g4
    case g5
    case g5D
}

public enum MalignantNeoplasm: CaseIterable, Hashable, Sendable {
    case no
    case pastHistory
    case underTreatment
}

public enum RutherfordClassification: CaseIterable, Hashable, Sendable {
    case class4
    case class5
    case class6
}
