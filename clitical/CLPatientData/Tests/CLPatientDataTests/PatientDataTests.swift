import Testing
@testable import CLPatientData

@Suite
struct PatientDataTests {
    @Test
    func testInit() {
        let pd = PatientData()
        // Sex has no clinically safe default: it must be chosen explicitly,
        // so an untouched form is distinguishable from a deliberate answer.
        #expect(pd.sex == nil)
        #expect(pd.age == nil)
        #expect(pd.height == nil)
        #expect(pd.weight == nil)
        #expect(pd.alb == nil)
        #expect(pd.activity == .ambulatory)
        #expect(!pd.hasCHF)
        #expect(!pd.hasCAD)
        #expect(!pd.hasCVD)
        #expect(pd.ckd == .normal)
        #expect(pd.malignantNeoplasm == .no)
        #expect(!pd.hasAILesion)
        #expect(!pd.hasFPLesion)
        #expect(!pd.hasBKLesion)
        #expect(!pd.isUrgent)
        #expect(!pd.hasFever)
        #expect(!pd.hasAbnormalWBC)
        #expect(!pd.hasLocalInfection)
        #expect(!pd.hasDyslipidemia)
        #expect(!pd.isSmoking)
        #expect(!pd.hasContraLateralLesion)
        #expect(!pd.hasOtherVD)
        #expect(pd.rutherford == .class4)
    }

    @Test
    func testValueSemantics() {
        var original = PatientData()
        original.age = 70
        var copy = original
        copy.age = 80
        #expect(original.age == 70)
        #expect(copy.age == 80)
    }

    @Test
    func testClearResetsToInitialState() {
        var pd = PatientData()
        pd.age = 70
        pd.height = 160.0
        pd.hasCHF = true
        pd.sex = .male
        pd.clear()
        #expect(pd.age == nil)
        #expect(pd.height == nil)
        #expect(!pd.hasCHF)
        #expect(pd.sex == nil)
    }
}
