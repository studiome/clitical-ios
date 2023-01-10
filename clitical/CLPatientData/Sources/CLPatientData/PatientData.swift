import Combine

@available(macOS 10.15, *)
@available(iOS 13.0, *)

public class PatientData: ObservableObject {
    @Published var sex: Sex = .female
    @Published var age: Int?
    @Published var height:Double?
    @Published var weight:Double?
    @Published var alb:Double?
    @Published var activity:Activity = .ambulatory
    @Published var hasCHF: Bool = false
    @Published var hasCAD: Bool  = false
    @Published var hasCVD: Bool = false
    @Published var ckd: CKD = .normal
    @Published var malignantNeoplasm: MalignantNeoplasm = .no
    @Published var hasAILesion: Bool = false
    @Published var hasFPLesion: Bool = false
    @Published var hasBKLesion: Bool = false
    @Published var isUrgent: Bool = false
    @Published var hasFever: Bool = false
    @Published var hasAbnormalWBC: Bool = false
    @Published var hasLocalInfection: Bool = false
    @Published var hasDyslipidemia: Bool = false
    @Published var isSmoking: Bool = false
    @Published var hasContraLateralLesion: Bool = false
    @Published var hasOtherVD: Bool = false
    @Published var rutherford: RutherfordClassification = .class4
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
