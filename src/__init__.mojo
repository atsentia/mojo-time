"""
Mojo Time Library

Pure Mojo datetime utilities providing:
- DateTime: Date and time representation with microsecond precision
- Duration: Time interval representation with nanosecond precision
- Timestamp: Unix timestamp handling
- Formatting: ISO 8601 / RFC 3339 formatting and parsing
- Clock: System clock access (monotonic and wall clock)

Designed for:
- JWT expiration handling
- Logging timestamps
- Rate limiter timing
- General datetime operations

Usage:
    from mojo_time import DateTime, Duration, Timestamp
    from mojo_time import format_iso8601, parse_iso8601
    from mojo_time import Clock, Stopwatch, Timer

    # Get current time
    var now = DateTime.now()
    print(format_iso8601(now))  # "2025-12-28T14:30:00Z"

    # Measure elapsed time
    var sw = Stopwatch.start_new()
    do_work()
    print("Elapsed:", sw.elapsed_ms(), "ms")

    # Create duration
    var d = Duration.from_minutes(5)
    var future = now.add(d)

    # Unix timestamps
    var ts = Timestamp.now()
    print("Unix time:", ts.seconds)
"""

from .datetime import DateTime, Date, Time
from .duration import Duration
from .timestamp import Timestamp, TimestampRange
from .clock import Clock, Stopwatch, Timer
from .format import (
    format_iso8601,
    format_rfc3339,
    format_rfc3339_millis,
    format_date,
    format_time,
    format_time_with_micros,
    format_unix_timestamp,
    format_human_readable,
    parse_iso8601,
    parse_date,
    parse_time,
    ParseResult,
    DateTimeFormatter,
)
