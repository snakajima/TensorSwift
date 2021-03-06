import XCTest
@testable import TensorSwift

private func getTensor1000x1000() -> Tensor {
    let elements = [Float](count: 1000*1000 ,repeatedValue:0.1)
    return Tensor(shape: [1000, 1000], elements: elements)
}

private func getTensor1x1000() -> Tensor {
    let elements = [Float](count: 1000, repeatedValue: 0)
    return Tensor(shape: [1, 1000], elements: elements)
}

class CalculationPerformanceTest : XCTestCase {
    func testElementAccess(){
        let W = getTensor1000x1000()
        measureBlock{
            for _ in 0..<100000{
                let _ = W[500,500]
            }
        }
    }
    
    func testElementAccessRaw(){
        let W = getTensor1000x1000()
        measureBlock{
            for _ in 0..<100000{
                let _ = W.elements[500*W.shape.dimensions[1].value + 500]
            }
        }
    }
    
    func testMultiplication(){
        let W = getTensor1000x1000()
        let x = getTensor1x1000()
        
        measureBlock{
            let _ = x.matmul(W)
        }
    }
    
    func testMultiplicationRaw() {
        let W = getTensor1000x1000()
        let x = getTensor1x1000()
        
        measureBlock{
            let xRow = x.shape.dimensions[0].value
            let WRow = W.shape.dimensions[0].value
            let WColumn = W.shape.dimensions[1].value
            var elements = [Float](count: 1000, repeatedValue: 0)
            for r in 0..<xRow {
                for i in 0..<WRow {
                    let tmp = x.elements[r * WRow + i]
                    for c in 0..<WColumn {
                        elements[r * WRow + c] = tmp * W.elements[i * WRow + c]
                    }
                }
            }
            let _ = Tensor(shape: [1,1000], elements: elements)
        }
    }
}