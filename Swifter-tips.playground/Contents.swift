//: Playground - noun: a place where people can play

import UIKit
import Foundation

// MARK: 对target-action的柯里化封装
protocol TargetAction {
    func performAction()
}

struct TargetActionWrapper<T: AnyObject>: TargetAction {
    weak var target: T?
    let action: (T) -> () -> ()
    
    func performAction() {
        if let t = target {
            action(t)()
        }
    }
}

enum ControlEvent {
    case TouchUpInside
    case ValueChanged
}

class Control {
    var actions = [ControlEvent: TargetAction]()
    
    func setTarget<T: AnyObject>(target: T, action: @escaping (T) -> ()->(), controlEvent: ControlEvent) {
        actions[controlEvent] = TargetActionWrapper(target: target, action: action)
    }
 	  
    func removeTargetFor(controlEvent: ControlEvent) {
        actions[controlEvent] = nil
    }
    
    func perActionFor(controlEvent: ControlEvent) {
        actions[controlEvent]?.performAction()
    }
}

final class MyViewController {
    let button = Control()
    
    init() {
        button.setTarget(target: self, action: MyViewController.onTapButton, controlEvent: .TouchUpInside)
    }
    
    func onTapButton() {
        print("Button tapped")
    }
}

let myVC = MyViewController()
myVC.button.perActionFor(controlEvent: .TouchUpInside)

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: protocol声明为mutating
protocol Vehicle {
    var numberOfWheels: Int { get }
    var color: UIColor { get set }
    mutating func changeColor()
}

struct MyCar: Vehicle {
    let numberOfWheels = 4
    var color = UIColor.blue
    
    mutating func changeColor() {
        self.color = .red
    }
}

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: Sequence
class ReverseIterator<T>: IteratorProtocol {
    typealias Element = T
    
    var array: [Element]
    var currentIndex = 0
    
    init(array: [Element]) {
        self.array = array
        currentIndex = array.count - 1
    }
    
    func next() -> Element? {
        if currentIndex < 0 {
            return nil
        } else {
            let element = array[currentIndex]
            currentIndex -= 1
            return element
        }
    }
}

struct ReverseSequence<T>: Sequence {
    var array: [T]
    
    init(array: [T]) {
        self.array = array
    }
    
    typealias Iterator = ReverseIterator<T>
    
    func makeIterator() -> ReverseIterator<T> {
        return ReverseIterator(array: self.array)
    }
}

let myarray = [0,1,2,3,4,5]
for (index, value) in ReverseSequence(array: myarray).enumerated() {
    print("Index \(index) is \(value)")
}
/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: Tuple
let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
let (small, large) = rect.divided(atDistance: 20, from: .minXEdge)
print("small \(small) large \(large)")
/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: Optional Chaining
class Toy {
    let name: String
    init(name: String) {
        self.name = name
    }
}

class Pet {
    var toy: Toy?
}

class Child {
    var pet: Pet?
}

extension Toy {
    func play() {
        
    }
}

let xiaoming = Child()
if let toyName = xiaoming.pet?.toy?.name {
    print("has a toy named \(toyName)")
}

// let playClosure = { (child: Child) -> () in child.pet?.toy?.play() }
let playClosure = { (child: Child) -> ()? in child.pet?.toy?.play() }

if let result: () = playClosure(xiaoming) {
    print("happy")
} else {
    print("sb...")
}

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: 操作符

struct Vector2D {
    var x = 0.0
    var y = 0.0
}

precedencegroup DotProductionPrecedence {
    associativity: none
    higherThan: MultiplicationPrecedence
}

infix operator +*: DotProductionPrecedence

func +*(lhs: Vector2D, rhs: Vector2D) -> Double {
    return lhs.x * rhs.x + lhs.y * rhs.y
}

let v1 = Vector2D(x: 4, y: 5)
let v2 = Vector2D(x: 3, y: 4)
print(v1 +* v2)

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: func的参数修饰
func makeIncrementor(stepNumber: Int) -> ((inout Int) -> ()) {
    func incrementor(variable: inout Int) {
        variable += stepNumber
    }
    
    return incrementor
}

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: 字面量
enum myTruth: Int {
    case myTrue, myFalse
}
extension myTruth: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: Bool) {
        self = value ? .myTrue : .myFalse
    }
}
let myT: myTruth = true
let myF: myTruth = false
print("myT \(myT), myF \(myF)")

class Person: ExpressibleByStringLiteral {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    required convenience init(stringLiteral value: String) {
        self.init(name: value)
    }
    
    required convenience init(unicodeScalarLiteral value: String) {
        self.init(name: value)
    }
    
    required convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(name: value)
    }
}

let person: Person = "xiaoqi"
print(person.name)

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: 下标

// MARK: - 一次性取出某几个位置的元素
extension Array {
    subscript(indecies: [Int]) -> ArraySlice<Element> {
        get {
            var results = ArraySlice<Element>()
            for index in indecies {
                assert(index < self.count, "Index Out Of Range")
                results.append(self[index])
            }
            return results
        }
        set {
            for (i, index) in indecies.enumerated() {
                assert(index < self.count, "Index Out Of Range")
                self[index] = newValue[i]
            }
        }
    }
    
    // 更优雅的实现
    subscript(first: Int, second: Int, others: Int...) -> ArraySlice<Element> {
        get {
            assert(first < self.count, "Index Out Of Range")
            assert(second < self.count, "Index Out Of Range")
            var results = ArraySlice<Element>(arrayLiteral: self[first], self[second])
            guard !others.isEmpty else {
                return results
            }
            for index in others {
                assert(index < self.count, "Index Out Of Range")
                results.append(self[index])
            }
            return results
        }
        set {
            assert(newValue.count == (2 + others.count), "Not Enough New Values")
            assert(first < self.count, "Index Out Of Range")
            assert(second < self.count, "Index Out Of Range")
            self[first] = newValue[newValue.startIndex]
            self[second] = newValue[newValue.startIndex.advanced(by: 1)]
            guard !others.isEmpty else { return }
            for (i, index) in others.enumerated() {
                assert(index < self.count, "Index Out Of Range")
                self[index] = newValue[i]
            }
        }
    }
}

var newArray = [1,1,3,4,56,7,8]
print(newArray[2, 3, 4])
newArray[2, 3, 4] = [18,19,20]
print(newArray)

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: associatedtype

//protocol Food {}
//protocol Animal {
//    func eat(_ food: Food)
//}
//struct Grass: Food {}
//struct Meat: Food {}
//struct Tiger: Animal {
//    func eat(_ food: Food) {
//        if let meat = food as? Meat {
//            print("Happy to eat \(meat)")
//        } else {
//            fatalError("NO NO NO NO")
//        }
//    }
//}

protocol Food {}
protocol Animal {
    associatedtype F: Food
    func eat(_ food: F)
}
struct Grass: Food {}
struct Meat: Food {}
struct Tiger: Animal {
    typealias F = Meat
    func eat(_ food: Meat) {
        print("Happy to eat \(food)")
    }
}

let grass = Grass()
let meat = Meat()
let tiger = Tiger()
tiger.eat(meat)
//tiger.eat(grass)


// **** protocol 'Animal' can only be used as a generic constraint because it has Self or associated type requirements
//func isDangerous(animal: Animal) -> Bool {
//    if animal is Tiger {
//        return true
//    } else {
//        return false
//    }
//}

func isDangerous<T: Animal>(animal: T) -> Bool {
    if animal is Tiger {
        return true
    } else {
        return false
    }
}
print("Is this animal dangerous? ", isDangerous(animal: tiger))

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: 继承
class ClassA {
    let num: Int
    
    required init(num: Int) {
        self.num = num
    }
    
    convenience init(bigNum: Bool) {
        self.init(num: bigNum ? 10000 : 1)
    }
}

class ClassB: ClassA {
    let times: Int
    
    required init(num: Int) {
        self.times = num + 1
        super.init(num: num)
    }
    
    convenience init(bigNum: Bool) {
        self.init(num: bigNum ? 20000 : 2)
    }
}

let anObj = ClassB(bigNum: true)
print(anObj.times)

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: 可失败初始化器

extension Int {
    init?(fromString string: String) {
        self = 0
        var digit = string.characters.count - 1
        print("digit:\(digit)")
        for c in string.characters {
            print("c is \(c)")
            var num = 0
            if let n = Int(String(c)) {
                num = n
            } else {
                switch c {
                case "一": num = 1
                case "二": num = 2
                case "三": num = 3
                case "四": num = 4
                case "五": num = 5
                case "六": num = 6
                case "七": num = 7
                case "八": num = 8
                case "九": num = 9
                case "零": num = 0
                default: return nil
                }
            }
            self += num * Int(pow(10, Double(digit)))
            digit -= 1
        }
    }
}

if let num = Int(fromString: "12") {
    print("12 is \(num)")
} else {
    print("12 is nil")
}
if let num = Int(fromString: "三四六八零") {
    print("三四六八零 is \(num)")
} else {
    print("三四六八零 is nil")
}
if let num = Int(fromString: "nihao") {
    print("nihao is \(num)")
} else {
    print("nihao is nil")
}
if let num = Int(fromString: "七八9五") {
    print("七八9五 is \(num)")
} else {
    print("七八9五 is nil")
}

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: static 和 class
