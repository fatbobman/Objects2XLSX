import Foundation
import Objects2XLSX

// MARK: - Command Line Arguments

struct CLIArguments {
    let dataSize: DataSize
    let outputPath: URL
    let styleTheme: StyleTheme
    let verbose: Bool
    let benchmark: Bool
    let help: Bool
    
    static func parse() -> CLIArguments {
        let args = CommandLine.arguments
        
        var dataSize = DataSize.medium
        var outputPath = URL(fileURLWithPath: "demo_output.xlsx")
        var styleTheme = StyleTheme.mixed
        var verbose = false
        var benchmark = false
        var help = false
        
        var i = 1
        while i < args.count {
            let arg = args[i]
            
            switch arg {
            case "-h", "--help":
                help = true
                
            case "-s", "--size":
                if i + 1 < args.count {
                    i += 1
                    switch args[i].lowercased() {
                    case "small": dataSize = .small
                    case "medium": dataSize = .medium
                    case "large": dataSize = .large
                    default:
                        print("⚠️  Unknown size '\(args[i])'. Using medium.")
                    }
                }
                
            case "-o", "--output":
                if i + 1 < args.count {
                    i += 1
                    outputPath = URL(fileURLWithPath: args[i])
                }
                
            case "-t", "--theme":
                if i + 1 < args.count {
                    i += 1
                    switch args[i].lowercased() {
                    case "corporate": styleTheme = .corporate
                    case "modern": styleTheme = .modern
                    case "default": styleTheme = .defaultTheme
                    case "mixed": styleTheme = .mixed
                    default:
                        print("⚠️  Unknown theme '\(args[i])'. Using mixed.")
                    }
                }
                
            case "-v", "--verbose":
                verbose = true
                
            case "-b", "--benchmark":
                benchmark = true
                
            default:
                if !arg.hasPrefix("-") {
                    // Treat as output path if no extension or .xlsx
                    outputPath = URL(fileURLWithPath: arg)
                } else {
                    print("⚠️  Unknown argument: \(arg)")
                }
            }
            
            i += 1
        }
        
        return CLIArguments(
            dataSize: dataSize,
            outputPath: outputPath,
            styleTheme: styleTheme,
            verbose: verbose,
            benchmark: benchmark,
            help: help
        )
    }
    
    static func printUsage() {
        print("""
        📊 Objects2XLSX Demo - Swift Excel Generation Library
        
        USAGE:
            objects2xlsx-demo [OPTIONS] [OUTPUT_FILE]
        
        OPTIONS:
            -h, --help              Show this help message
            -s, --size SIZE         Data size: small, medium, large (default: medium)
            -o, --output PATH       Output file path (default: demo_output.xlsx)
            -t, --theme THEME       Style theme: corporate, modern, default, mixed (default: mixed)
            -v, --verbose           Enable verbose output with progress tracking
            -b, --benchmark         Show performance benchmarks
        
        EXAMPLES:
            objects2xlsx-demo
            objects2xlsx-demo report.xlsx
            objects2xlsx-demo -s large -t corporate -v output.xlsx
            objects2xlsx-demo --size small --theme modern --verbose --benchmark
        
        THEMES:
            corporate  - Professional corporate styling for all sheets
            modern     - Contemporary modern styling for all sheets
            default    - Excel default styling for all sheets
            mixed      - Different styling theme for each sheet (recommended)
        
        DATA SIZES:
            small      - \(DataSize.small.recordCount) records per sheet
            medium     - \(DataSize.medium.recordCount) records per sheet
            large      - \(DataSize.large.recordCount) records per sheet
        
        """)
    }
}

// MARK: - Demo Runner

struct DemoRunner {
    static func run() async throws {
        // Parse command line arguments
        let args = CLIArguments.parse()
        
        // Show help if requested
        if args.help {
            CLIArguments.printUsage()
            return
        }
        
        print("🚀 Objects2XLSX Demo Starting...")
        
        // Create and run the Excel generator
        let generator = ExcelGenerator(
            dataSize: args.dataSize,
            outputPath: args.outputPath,
            styleTheme: args.styleTheme,
            verbose: args.verbose,
            benchmark: args.benchmark
        )
        
        try await generator.generateWorkbook()
    }
}

// MARK: - Main Entry Point

let task = Task {
    do {
        try await DemoRunner.run()
    } catch {
        print("❌ Demo failed with error: \(error)")
        if let bookError = error as? BookError {
            print("   📋 Details: \(bookError)")
        }
        exit(1)
    }
}

// Wait for completion (extended timeout for large datasets)
await task.value