"""
Example: DateTime Operations

Demonstrates:
- Current time and timestamps
- Duration calculations
- ISO 8601 formatting
- Stopwatch for timing
"""

from mojo_time import DateTime, Duration, Timestamp
from mojo_time import format_iso8601, parse_iso8601, format_human_readable
from mojo_time import Clock, Stopwatch, Timer


fn current_time_example():
    """Get current time."""
    print("=== Current Time ===")

    # Get current datetime
    var now = DateTime.now()
    print("Current time: " + format_iso8601(now))

    # Unix timestamp
    var ts = Timestamp.now()
    print("Unix timestamp: " + String(ts.seconds))

    # Components
    print("Year: " + String(now.year))
    print("Month: " + String(now.month))
    print("Day: " + String(now.day))
    print("Hour: " + String(now.hour))
    print("Minute: " + String(now.minute))
    print("Second: " + String(now.second))
    print("")


fn duration_example():
    """Work with durations."""
    print("=== Duration ===")

    # Create durations
    var d1 = Duration.from_seconds(90)
    var d2 = Duration.from_minutes(5)
    var d3 = Duration.from_hours(2)
    var d4 = Duration.from_milliseconds(1500)

    print("90 seconds = " + String(d1.total_minutes()) + " minutes")
    print("5 minutes = " + String(d2.total_seconds()) + " seconds")
    print("2 hours = " + String(d3.total_minutes()) + " minutes")
    print("1500ms = " + String(d4.total_seconds()) + " seconds")

    # Add duration to datetime
    var now = DateTime.now()
    var future = now.add(Duration.from_hours(1))
    print("In 1 hour: " + format_iso8601(future))
    print("")


fn formatting_example():
    """Format dates and times."""
    print("=== Formatting ===")

    var now = DateTime.now()

    # ISO 8601
    print("ISO 8601: " + format_iso8601(now))

    # RFC 3339 (with milliseconds)
    print("RFC 3339: " + format_rfc3339_millis(now))

    # Date only
    print("Date: " + format_date(now))

    # Time only
    print("Time: " + format_time(now))

    # Human readable
    print("Human: " + format_human_readable(now))

    # Unix timestamp
    print("Unix: " + format_unix_timestamp(now))
    print("")


fn parsing_example():
    """Parse date strings."""
    print("=== Parsing ===")

    # Parse ISO 8601
    var dt = parse_iso8601("2025-12-28T14:30:00Z")
    if dt.is_ok():
        print("Parsed: " + format_iso8601(dt.value()))

    # Parse date
    var date = parse_date("2025-12-28")
    if date.is_ok():
        print("Date: " + String(date.value().year) + "-" + String(date.value().month))

    # Parse time
    var time = parse_time("14:30:00")
    if time.is_ok():
        print("Time: " + String(time.value().hour) + ":" + String(time.value().minute))
    print("")


fn stopwatch_example():
    """Measure elapsed time."""
    print("=== Stopwatch ===")

    # Start stopwatch
    var sw = Stopwatch.start_new()

    # Simulate work
    var sum = 0
    for i in range(1000000):
        sum += i

    # Check elapsed
    print("Elapsed: " + String(sw.elapsed_ms()) + " ms")
    print("Elapsed: " + String(sw.elapsed_micros()) + " us")

    # Stop and restart
    sw.stop()
    print("Stopped")

    sw.reset()
    sw.start()
    print("Restarted")
    print("")


fn timer_example():
    """Deadline timer."""
    print("=== Timer ===")

    # Create timer with 5 second deadline
    var timer = Timer.start(Duration.from_seconds(5))

    print("Timer started: 5 second deadline")
    print("Is expired: " + String(timer.is_expired()))
    print("Remaining: " + String(timer.remaining_ms()) + " ms")

    # Use for request timeouts
    # while not timer.is_expired():
    #     process_request()
    print("")


fn main():
    print("mojo-time: DateTime Operations\n")

    current_time_example()
    duration_example()
    formatting_example()
    parsing_example()
    stopwatch_example()
    timer_example()

    print("=" * 50)
    print("Use cases:")
    print("  - JWT expiration")
    print("  - Logging timestamps")
    print("  - Rate limiter timing")
    print("  - Request timeouts")
