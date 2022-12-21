public struct CLPatientData {
    
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
        sex = Sex.Female;
        activity = Activity.Ambulatory;
        hasCHF = false;
        hasCAD = false;
        hasCVD = false;
        ckd = .Normal;
        malignantNeoplasm = .No;
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
        rutherford = .Class4;
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

public enum MalignantNeoplasm{
    case No
    case PastHistory
    case UnderTreatment
}

public enum RutherfordClassification{
    case Class4
    case Class5
    case Class6
}
