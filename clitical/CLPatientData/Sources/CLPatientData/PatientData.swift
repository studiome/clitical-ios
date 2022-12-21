public struct PatientData {
    
    public var sex: Sex
    public var age: Int?
    public var height:Double?
    public var weight:Double?
    public var alb:Double?
    public var activity:Activity
    public var hasCHF: Bool
    public var hasCAD: Bool
    public var hasCVD: Bool
    public var ckd: CKD
    public var malignantNeoplasm: MalignantNeoplasm
    public var hasAILesion: Bool
    public var hasFPLesion: Bool
    public var hasBKLesion: Bool
    public var isUrgent: Bool
    public var hasFever: Bool
    public var hasAbnormalWBC: Bool
    public var hasLocalInfection: Bool
    public var hasDyslipidemia: Bool
    public var isSmoking: Bool
    public var hasContraLateralLesion: Bool
    public var hasOtherVD: Bool
    public var rutherford: RutherfordClassification
    
    public init() {
        sex = Sex.female;
        activity = Activity.ambulatory;
        hasCHF = false;
        hasCAD = false;
        hasCVD = false;
        ckd = .normal;
        malignantNeoplasm = .no;
        hasAILesion = false;
        hasFPLesion = false;
        hasBKLesion = false;
        isUrgent = false;
        hasFever = false;
        hasAbnormalWBC = false;
        hasLocalInfection = false;
        hasDyslipidemia = false;
        isSmoking = false;
        hasContraLateralLesion = false;
        hasOtherVD = false;
        rutherford = .class4;
    }
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
