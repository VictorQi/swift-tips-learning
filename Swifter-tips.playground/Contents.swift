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
let toy = Toy(name: "haha")
let pet = Pet()
pet.toy = toy
let xiaoming = Child()
xiaoming.pet = pet
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
    
    class var name: String {
        return "Victor Qi"
    }
    
    required init(num: Int) {
        self.num = num
    }
    
    convenience init(bigNum: Bool) {
        self.init(num: bigNum ? 10000 : 1)
    }
}

class ClassB: ClassA {
    let times: Int
    
    override static var name: String {
        return "Qi JianQiong"
    }
    
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
struct MyPoint: CustomStringConvertible {
    let x: Double
    let y: Double
    
    static let zero = MyPoint(x: 0, y: 0)
    
    static let ones: [MyPoint] = [MyPoint(x: -1, y: -1),
                                  MyPoint(x: -1, y: 1),
                                  MyPoint(x: 1, y: 1),
                                  MyPoint(x: 1, y: -1)]
    
    static func add(_ lhs: MyPoint, _ rhs: MyPoint) -> MyPoint {
        return MyPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    var description: String {
        return "MyPoint(x: \(x), y: \(y))"
    }
}

let zero = MyPoint.zero
let one = MyPoint.ones[1]
let newOne = MyPoint.add(zero, one)
print(zero, one, newOne)

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: 多类型和容器
enum IntOrString {
    case intValue(Int)
    case stringValue(String)
}
let mixed = [IntOrString.intValue(10),
             IntOrString.stringValue("Nihao"),
             IntOrString.stringValue("Sb"),
             IntOrString.intValue(22)]
for value in mixed {
    switch value {
    case let .intValue(i):
        print("Int Value \(i)")
    case let .stringValue(string):
        print("String Value \(string)")
    }
}

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: 正则表达式
struct RegexHelper {
    let regex: NSRegularExpression
    
    init(_ patten: String) throws{
        try regex = NSRegularExpression(pattern: patten, options: .caseInsensitive)
    }
    
    func match(_ input: String) -> Bool {
        let matches = regex.matches(in: input, options: [], range: NSMakeRange(0, input.utf8.count))
        return matches.count > 0
    }
}
func emailMatch() -> Bool {
    let matchPatten = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
    guard let matcher = try? RegexHelper(matchPatten) else {
        print("regex sb le")
        return false
    }
    let emailAddress = "qijianqiong@gmail.com"
    if matcher.match(emailAddress) {
        print("nice email")
        return true
    } else {
        return false
    }
}
emailMatch()

precedencegroup MatchPrecedence {
    higherThan: DefaultPrecedence
}
infix operator =~: MatchPrecedence
func =~(lhs: String, rhs: String) -> Bool {
    do {
        return try RegexHelper(rhs).match(lhs)
    } catch {
        return false
    }
}
if "qijianqiong@gmail.com" =~ "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$" {
    print("nice")
}

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: 模式匹配
if -1.0...1.0 ~= 0.5 {
    print("0.5 is in")
} else {
    print("0.5 is out")
}
let password = "nihaodashabi"
if "nihaodashabi" ~= password {
    print("check in")
} else {
    print("check failed")
}
let numNil: Int? = nil
if nil ~= numNil {
    print("nil")
}

func ~=(patten: NSRegularExpression, input: String) -> Bool {
    return patten.numberOfMatches(in: input, options: [], range: NSMakeRange(0, input.utf8.count)) > 0
}

prefix operator ~/
prefix func ~/(patten: String) throws -> NSRegularExpression {
    return try NSRegularExpression(pattern: patten, options: .caseInsensitive)
}

let contact = ("qijianqiong@gmail.com", "http://victorqi.com")
func testRegexInSwitch(inputs: (String, String)) {
    let mail = try? ~/"^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
    let site = try? ~/"^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
    guard let mailRegex = mail, let siteRegex = site else {
        print("~/ operator failed")
        return
    }
    switch inputs {
    case (mailRegex, siteRegex): print("有枪有炮")
    case (_, siteRegex): print("有炮")
    case (mailRegex, _): print("有枪")
    case (_, _): print("啥都么得")
    }
}
testRegexInSwitch(inputs: contact)

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: ..< & ...
let tests = "qiJianqiong"
let words = "a" ... "z"
for c in tests.characters {
    if !words.contains(String(c)) {
        print("\(c) 不是小写的")
    }
}

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: AnyClass 元类型 .self
let typeA: ClassA.Type = ClassA.self
let typeB: AnyClass = ClassB.self
print("typeA is \(typeA), typeB is \(typeB)")
print("typeA's name is \(typeA.name)")
print("typeB's name is \((typeB as! ClassB.Type).name)")

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: 协议中的Self
protocol Copyable {
    func copy() -> Self
}

class MyClass: Copyable {
    var num = 1
    
    required init() {}
    
    func copy() -> Self {
        let result = type(of: self).init()
        result.num = self.num
        return result
    }
}

let object = MyClass()
object.num = 5

let newObject = object.copy()

object.num = 15

print("object.num \(object.num) newObject.num \(newObject.num)")

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: 属性观察
class DateClass {
    var date: Date {
        willSet {
            print("即将从\(date)设定为\(newValue)")
        }
        didSet {
            print("已经从\(oldValue)设定到\(date)")
        }
    }
    
    var name: String {
        set {
            print("set")
        }
        
        get {
            return "victor qi"
        }
    }
    
    init() {
        self.date = Date()
    }
}

let foo = DateClass()
foo.date.addTimeInterval(10086)
print("now date is", foo.date)

class A {
    var num: Int {
        get {
            print("get")
            return 1
        }
        set { print("set") }
    }
}
class B: A {
    override var num: Int {
        willSet { print("willSet") }
        didSet { print("didSet") } //会打印get，didSet需要获取旧值并存储起来，因此会调用一次get
    }
}
let b = B()
b.num = 3

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: final
class Parent {
    final func method() {
        print("开始配置")
        methodImpl()
        print("结束配置")
    }
    
    func methodImpl() {
        fatalError("子类必须实现这个方法")
    }
}

class NewChild: Parent {
    override func methodImpl() {
        print("正在配置")
    }
}
let newChild = NewChild()
newChild.method()

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: lazy
let data = 1...3
//let resultD = data.map { (i: Int) -> Int in
//    print("正在处理\(i)")
//    return i * 2
//}
let resultD = data.lazy.map { (i) -> Int in
    print("正在处理\(i)")
    return i * 2
}
print("准备访问结果")
for i in resultD {
    print("操作后的结果为\(i)")
}
print("访问结束")

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: 反射和Mirror
let r = Mirror(reflecting: xiaoming)
print("xiaoming is \(r.displayStyle!)")
print("xiaoming has \(r.children.count) children")
for child in r.children {
    print("property is \(child.label!), value is \(child.value)")
}
dump(xiaoming)

func valueFrom(_ object: Any, key: String) -> Any? {
    let reflection = Mirror(reflecting: object)
    
    for child in reflection.children {
        let (targetKey, targetMirror) = (child.label, child.value)
        if targetKey == key {
            return targetMirror
        }
    }
    return nil
}

if let name = valueFrom(xiaoming, key: "pet") as? Pet {
    print("通过key得到值: \(name)")
}

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: 多重Optional
var aNil: String? = nil
var anotherNil: String?? = aNil //两者不同，anthoerNil这个多重Optional是一层Enum容器中.Some条件包含值aNil，而aNil是一层Enum容器中的.None
var literalNil: String?? = nil  //literalNil则是一层Enum容器中的.None

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: 协议扩展
protocol A2 {
    func method() -> String
}

extension A2 {
    func method() -> String {
        return "Hello."
    }
    
    func method1() -> String {
        return "Hi!"
    }
}

struct B1: A2 {
    func method() -> String {
        return "Hello! Victor."
    }
    
    func method1() -> String {
        return "Nice! Well done."
    }
}

let b1 = B1()
print(b1.method())
print(b1.method1())

let b2: A2 = B1()
print(b2.method())
print(b2.method1())
print("\n ----------------------------------------- \n")
/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

// MARK: indirecth和嵌套Enum
indirect enum LinkedList<Element: Comparable> {
    case empty
    case node(Element, LinkedList<Element>)
    
    func remove(_ element: Element) -> LinkedList<Element> {
        guard case let .node(value, next) = self else {
            print("empty")
            print("\n ----------------------------------------- \n")
            return .empty
        }
        print("value is \(value)")
        if value == element {
            print("next is \(next)")
            print("\n ----------------------------------------- \n")
            return next
        } else {
            let newNext = next.remove(element)
            print("next.remove(element) is \(newNext)")
            print("\n ----------------------------------------- \n")
            return LinkedList.node(value, newNext)
        }
    }
}
let linklist = LinkedList.node(1, .node(2, .node(3, .node(4, .empty))))
//print(linklist)
let linklist1 = linklist.remove(4)
//print(linklist1)
