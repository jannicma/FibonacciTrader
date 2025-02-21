// The Swift Programming Language
// https://docs.swift.org/swift-book

@main
struct Main{
    static func main() async {
        let backtestActor = BacktestActor()
        while true{
            print("\n\n\n")
            print("""
                Fibonacci Trader!
                --------------------
                1: Create Backtest (in progress)
                2: Start live trading (to do)
                3: Get live trading stats (to do)
                4: Stop live trading (to do)
                q: Exit full program - stops everything!
                """)

            if let input = readLine(){
                switch input{
                    case "1": 
                        print()
                        await backtestActor.startBacktest()
                    case "2":
                        print("start live")
                    case "3":
                        print("live stats")
                    case "4":
                        print("stop live")
                    case "q":
                        return
                    default:
                        print("invalid option")
                }
            }
        }
    }
}   
