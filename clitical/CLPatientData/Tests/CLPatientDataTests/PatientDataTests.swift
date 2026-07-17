import Testing
@testable import CLPatientData

@Suite struct PatientDataTests {
    @Test func testInit() {
        let pd = PatientData()
        #expect(pd.sex == .female)
        #expect(pd.age == nil)
        #expect(pd.height == nil)
        #expect(pd.weight == nil)
        #expect(pd.alb == nil)
        #expect(pd.activity == .ambulatory)
        #expect(pd.hasCHF == false)
        #expect(pd.hasCAD == false)
        #expect(pd.hasCVD == false)
        #expect(pd.ckd == .normal)
        #expect(pd.malignantNeoplasm == .no)
        #expect(pd.hasAILesion == false)
        #expect(pd.hasFPLesion == false)
        #expect(pd.hasBKLesion == false)
        #expect(pd.isUrgent == false)
        #expect(pd.hasFever == false)
        #expect(pd.hasAbnormalWBC == false)
        #expect(pd.hasLocalInfection == false)
        #expect(pd.hasDyslipidemia == false)
        #expect(pd.isSmoking == false)
        #expect(pd.hasContraLateralLesion == false)
        #expect(pd.hasOtherVD == false)
        #expect(pd.rutherford == .class4)
    }

    @Test func testValueSemantics() {
        var original = PatientData()
        original.age = 70
        var copy = original
        copy.age = 80
        #expect(original.age == 70)
        #expect(copy.age == 80)
    }

    @Test func testClearResetsToInitialState() {
        var pd = PatientData()
        pd.age = 70
        pd.height = 160.0
        pd.hasCHF = true
        pd.clear()
        #expect(pd.age == nil)
        #expect(pd.height == nil)
        #expect(pd.hasCHF == false)
        #expect(pd.sex == .female)
    }
}
