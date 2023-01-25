import Combine

@available(macOS 10.15, *)
@available(iOS 13.0, *)

public class PatientData: ObservableObject {
    @Published public var sex: Sex
    @Published public var age: Int?
    @Published public var height:Double? //cm
    @Published public var weight:Double? //kg
    @Published public var alb:Double?
    @Published public var activity:Activity
    @Published public var hasCHF: Bool
    @Published public var hasCAD: Bool
    @Published public var hasCVD: Bool
    @Published public var ckd: CKD = .normal
    @Published public var malignantNeoplasm: MalignantNeoplasm
    @Published public var hasAILesion: Bool
    @Published public var hasFPLesion: Bool
    @Published public var hasBKLesion: Bool
    @Published public var isUrgent: Bool
    @Published public var hasFever: Bool
    @Published public var hasAbnormalWBC: Bool
    @Published public var hasLocalInfection: Bool
    @Published public var hasDyslipidemia: Bool
    @Published public var isSmoking: Bool
    @Published public var hasContraLateralLesion: Bool
    @Published public var hasOtherVD: Bool
    @Published public var rutherford: RutherfordClassification
    
    public init(){
         sex = .female
         activity = .ambulatory
         hasCHF = false
         hasCAD  = false
         hasCVD = false
         ckd = .normal
         malignantNeoplasm = .no
         hasAILesion = false
         hasFPLesion = false
         hasBKLesion = false
         isUrgent = false
         hasFever = false
         hasAbnormalWBC = false
         hasLocalInfection = false
         hasDyslipidemia = false
         isSmoking = false
         hasContraLateralLesion = false
         hasOtherVD = false
         rutherford = .class4
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
