public struct PatientData {
    
    public var sex: Sex = .female
    public var age: Int?
    public var height:Double?
    public var weight:Double?
    public var alb:Double?
    public var activity:Activity = .ambulatory
    public var hasCHF: Bool = false
    public var hasCAD: Bool  = false
    public var hasCVD: Bool = false
    public var ckd: CKD = CKD.normal
    public var malignantNeoplasm: MalignantNeoplasm = .no
    public var hasAILesion: Bool = false
    public var hasFPLesion: Bool = false
    public var hasBKLesion: Bool = false
    public var isUrgent: Bool = false
    public var hasFever: Bool = false
    public var hasAbnormalWBC: Bool = false
    public var hasLocalInfection: Bool = false
    public var hasDyslipidemia: Bool = false
    public var isSmoking: Bool = false
    public var hasContraLateralLesion: Bool = false
    public var hasOtherVD: Bool = false
    public var rutherford: RutherfordClassification = .class4
}

public enum Sex{
    case male
    case female
}

public enum Activity{
    case ambulatory
    case wheelchair
    case immobile
}

public enum CKD{
    case normal
    case g3
    case g4
    case g5
    case g5D
}

public enum MalignantNeoplasm{
    case no
    case pastHistory
    case underTreatment
}

public enum RutherfordClassification{
    case class4
    case class5
    case class6
}
