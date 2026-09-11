import XCTest

extension XCTestCase {
    
    /// Waits until `condition` becomes true, then returns. Fails the test if
    /// it is still false after `timeout` seconds.
    ///
    /// WHY THIS IS NEEDED
    ///
    /// Some UIKit work does not happen on the line you trigger it. Pushing or
    /// replacing view controllers *with an animation* is queued, and applied
    /// on the next pass of the run loop. So this would fail:
    ///
    ///     coordinator.start()
    ///     XCTAssertTrue(navigation.viewControllers.first is TabbarVC) // not yet!
    ///
    /// `RunLoop.current.run(until:)` lets the app do that queued work for a
    /// moment. We check the condition after each short pass and stop as soon
    /// as it is true, so a passing test stays fast.
    func wait(until condition: () -> Bool,
              timeout: TimeInterval = 2,
              file: StaticString = #filePath,
              line: UInt = #line) {
        let deadline = Date().addingTimeInterval(timeout)
        
        while !condition() && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        }
        
        XCTAssertTrue(condition(),
                      "Condition was still false after \(timeout) seconds",
                      file: file, line: line)
    }
}
