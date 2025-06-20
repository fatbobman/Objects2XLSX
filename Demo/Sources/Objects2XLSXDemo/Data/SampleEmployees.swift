//
// SampleEmployees.swift
// Objects2XLSXDemo
//
// Sample employee data generator for demonstration
//

import Foundation

// MARK: - Sample Employee Data Generator

/// Generator for sample employee data
struct SampleEmployees {
    
    // MARK: - Data Arrays
    
    /// First names for employee generation
    private static let firstNames = [
        "Alice", "Bob", "Carol", "David", "Emma", "Frank", "Grace", "Henry",
        "Isabella", "James", "Katherine", "Liam", "Maya", "Nathan", "Olivia", "Peter",
        "Quinn", "Rachel", "Samuel", "Taylor", "Uma", "Victor", "Wendy", "Xavier",
        "Yara", "Zachary", "Aria", "Benjamin", "Charlotte", "Daniel", "Eleanor", "Felix",
        "Gabrielle", "Harper", "Isaac", "Jasmine", "Kevin", "Luna", "Marcus", "Nora",
        "Owen", "Penelope", "Rafael", "Sophia", "Theodore", "Violet", "William", "Zoe"
    ]
    
    /// Last names for employee generation
    private static let lastNames = [
        "Anderson", "Brown", "Chen", "Davis", "Evans", "Fischer", "Garcia", "Harris",
        "Jackson", "Johnson", "Kim", "Lee", "Martinez", "Miller", "Nguyen", "O'Connor",
        "Patel", "Rodriguez", "Smith", "Taylor", "Thompson", "Williams", "Wilson", "Young",
        "Adams", "Baker", "Clark", "Cooper", "Edwards", "Green", "Hall", "Hill",
        "King", "Lewis", "Moore", "Parker", "Roberts", "Turner", "Walker", "White"
    ]
    
    /// Cities for address generation
    private static let cities = [
        "San Francisco, CA", "New York, NY", "Seattle, WA", "Austin, TX", "Boston, MA",
        "Denver, CO", "Chicago, IL", "Los Angeles, CA", "Miami, FL", "Portland, OR",
        "Atlanta, GA", "Dallas, TX", "Phoenix, AZ", "Philadelphia, PA", "San Diego, CA"
    ]
    
    /// Street names for address generation
    private static let streetNames = [
        "Main St", "Oak Ave", "Park Blvd", "First St", "Second Ave", "Elm St",
        "Maple Ave", "Cedar St", "Pine St", "Washington Blvd", "Lincoln Ave",
        "Market St", "Broadway", "Church St", "School St"
    ]
    
    // MARK: - Generation Logic
    
    /// Generate sample employee data
    /// - Parameter size: Data size (small, medium, large)
    /// - Returns: Array of sample employees
    static func generate(size: DataSize = .medium) -> [Employee] {
        let count = size.recordCount
        var employees: [Employee] = []
        
        // Use a seeded random number generator for consistent results
        var randomGenerator = SeededRandomGenerator(seed: 42)
        
        for i in 0..<count {
            let employee = generateEmployee(index: i, using: &randomGenerator)
            employees.append(employee)
        }
        
        return employees
    }
    
    /// Generate a single employee with realistic data
    /// - Parameters:
    ///   - index: Employee index for unique identification
    ///   - randomGenerator: Seeded random generator for consistent results
    /// - Returns: Generated employee
    private static func generateEmployee(index: Int, using randomGenerator: inout SeededRandomGenerator) -> Employee {
        // Generate name
        let firstName = firstNames[randomGenerator.next(max: firstNames.count)]
        let lastName = lastNames[randomGenerator.next(max: lastNames.count)]
        let name = "\(firstName) \(lastName)"
        
        // Generate age (most >= 18, some < 18 for filtering demo)
        let age: Int
        if randomGenerator.next(max: 10) == 0 { // 10% chance of being under 18
            age = randomGenerator.next(range: 16...17)
        } else {
            age = randomGenerator.next(range: 22...65)
        }
        
        // Generate department (weighted distribution)
        let department: Employee.Department
        let deptRoll = randomGenerator.next(max: 100)
        switch deptRoll {
        case 0..<30: department = .engineering
        case 30..<45: department = .sales
        case 45..<60: department = .marketing
        case 60..<75: department = .operations
        case 75..<85: department = .finance
        default: department = .hr
        }
        
        // Generate salary (some nil for nil handling demo)
        let salary: Double?
        if randomGenerator.next(max: 10) == 0 { // 10% chance of nil salary
            salary = nil
        } else {
            let baseSalary: Double
            switch department {
            case .engineering:
                baseSalary = Double(randomGenerator.next(range: 75000...140000))
            case .sales:
                baseSalary = Double(randomGenerator.next(range: 50000...120000))
            case .marketing:
                baseSalary = Double(randomGenerator.next(range: 55000...100000))
            case .finance:
                baseSalary = Double(randomGenerator.next(range: 60000...110000))
            case .hr:
                baseSalary = Double(randomGenerator.next(range: 50000...90000))
            case .operations:
                baseSalary = Double(randomGenerator.next(range: 45000...85000))
            }
            salary = baseSalary
        }
        
        // Generate email
        let emailDomain = randomGenerator.next(max: 3) == 0 ? "company.com" : "enterprise.org"
        let emailPrefix = "\(firstName.lowercased()).\(lastName.lowercased())"
        let email = URL(string: "mailto:\(emailPrefix)@\(emailDomain)")!
        
        // Generate hire date (past 5 years)
        let currentDate = Date()
        let daysSinceStart = randomGenerator.next(max: 1825) // ~5 years in days
        let hireDate = Calendar.current.date(byAdding: .day, value: -daysSinceStart, to: currentDate)!
        
        // Generate manager status (20% managers)
        let isManager = randomGenerator.next(max: 5) == 0
        
        // Generate address (30% nil for nil handling demo)
        let address: String?
        if randomGenerator.next(max: 10) < 3 { // 30% chance of nil address
            address = nil
        } else {
            let streetNumber = randomGenerator.next(range: 100...9999)
            let streetName = streetNames[randomGenerator.next(max: streetNames.count)]
            let city = cities[randomGenerator.next(max: cities.count)]
            address = "\(streetNumber) \(streetName), \(city)"
        }
        
        return Employee(
            name: name,
            age: age,
            department: department,
            salary: salary,
            email: email,
            hireDate: hireDate,
            isManager: isManager,
            address: address
        )
    }
}


