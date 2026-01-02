# mojo-time

Pure Mojo datetime utilities library providing DateTime, Duration, Timestamp, and formatting capabilities.

## Features

- **DateTime**: Full date and time representation with microsecond precision
- **Duration**: Time intervals with nanosecond precision and arithmetic
- **Timestamp**: Unix timestamp handling with conversion methods
- **Formatting**: ISO 8601 and RFC 3339 formatting and parsing
- **Clock**: System clock access (monotonic and wall clock)
- **Utilities**: Stopwatch and Timer for common timing operations

## Installation

Add to your `pixi.toml`:

```toml
[dependencies]
mojo-time = { path = "../mojo-time" }
```

## Usage

### DateTime

```mojo
from mojo_time import DateTime, Duration

# Get current time
var now = DateTime.now()
print(now.year, now.month, now.day)

# Create specific datetime
var dt = DateTime(2025, 12, 28, 14, 30, 0, 0)

# Add time
var future = dt.add_hours(2)
var next_week = dt.add_days(7)

# Compare datetimes
if future > dt:
    print("Future is later")

# Start/end of day
var start = dt.start_of_day()
var end = dt.end_of_day()
```

### Duration

```mojo
from mojo_time import Duration

# Create durations
var d1 = Duration.from_seconds(30)
var d2 = Duration.from_milliseconds(500)
var d3 = Duration.from_minutes(5)
var d4 = Duration.from_hours(2)

# Arithmetic
var total = d1 + d2
var diff = d3 - d1
var doubled = d1 * 2

# Conversions
print(total.to_milliseconds())  # 30500
print(d4.to_seconds())          # 7200.0
print(d3.to_minutes())          # 5.0

# String representation
print(str(d4))  # "2h"
```

### Timestamp

```mojo
from mojo_time import Timestamp, DateTime

# Get current Unix timestamp
var ts = Timestamp.now()
print("Unix time:", ts.seconds)

# Create from specific values
var ts1 = Timestamp.from_seconds(1735400000)
var ts2 = Timestamp.from_milliseconds(1735400000500)

# Convert to DateTime
var dt = DateTime.from_timestamp(ts)

# Convert DateTime to Timestamp
var ts3 = dt.to_timestamp()
```

### Formatting

```mojo
from mojo_time import DateTime, format_iso8601, format_rfc3339, parse_iso8601

var dt = DateTime(2025, 12, 28, 14, 30, 45, 123456)

# ISO 8601 (no fractional seconds)
print(format_iso8601(dt))  # "2025-12-28T14:30:45Z"

# RFC 3339 with microseconds
print(format_rfc3339(dt))  # "2025-12-28T14:30:45.123456Z"

# Parse datetime strings
var result = parse_iso8601("2025-12-28T14:30:45.123456Z")
if result.success:
    print(result.datetime.year)  # 2025
else:
    print("Parse error:", result.error)
```

### Clock and Timing

```mojo
from mojo_time import Clock, Stopwatch, Timer

# Monotonic time for measuring durations
var start = Clock.monotonic_ns()
do_work()
var elapsed_ns = Clock.monotonic_ns() - start

# Unix timestamps
var unix_time = Clock.unix_timestamp()
var unix_ms = Clock.unix_timestamp_ms()

# Stopwatch for measuring elapsed time
var sw = Stopwatch.start_new()
do_work()
print("Elapsed:", sw.elapsed_ms(), "ms")
sw.stop()
sw.reset()

# Timer for deadlines
var timer = Timer.start_ms(5000)  # 5 second timeout
while not timer.is_expired():
    if try_operation():
        break
    print("Remaining:", timer.remaining_ms(), "ms")
```

## Use Cases

### JWT Expiration

```mojo
from mojo_time import DateTime, Duration, Timestamp

# Create JWT with expiration
var now = DateTime.now()
var expiration = now.add_minutes(60)  # Expires in 1 hour
var exp_timestamp = expiration.to_unix_seconds()

# Check if JWT is expired
fn is_expired(exp: Int) raises -> Bool:
    var current = Clock.unix_timestamp()
    return current >= exp
```

### Logging Timestamps

```mojo
from mojo_time import DateTime, format_rfc3339

fn log_message(level: String, message: String) raises:
    var now = DateTime.now()
    var timestamp = format_rfc3339(now)
    print(timestamp, "[", level, "]", message)

# Output: 2025-12-28T14:30:45.123456Z [ INFO ] Application started
```

### Rate Limiter Timing

```mojo
from mojo_time import Clock, Duration

struct RateLimiter:
    var last_request_ns: Int
    var min_interval_ns: Int

    fn __init__(inout self, requests_per_second: Int):
        self.last_request_ns = 0
        self.min_interval_ns = 1_000_000_000 // requests_per_second

    fn is_allowed(inout self) -> Bool:
        var now = Clock.monotonic_ns()
        if now - self.last_request_ns >= self.min_interval_ns:
            self.last_request_ns = now
            return True
        return False
```

## API Reference

### DateTime

| Method | Description |
|--------|-------------|
| `DateTime.now()` | Get current UTC datetime |
| `DateTime.from_timestamp(ts)` | Create from Unix timestamp |
| `dt.to_timestamp()` | Convert to Unix timestamp |
| `dt.add(duration)` | Add duration |
| `dt.subtract(duration)` | Subtract duration |
| `dt.add_hours(n)` | Add n hours |
| `dt.add_days(n)` | Add n days |
| `dt.start_of_day()` | Midnight of same day |
| `dt.end_of_day()` | 23:59:59.999999 of same day |
| `dt.is_leap_year()` | Check if leap year |
| `dt.day_of_year()` | Day number (1-366) |
| `dt.day_of_week()` | Weekday (0=Monday) |

### Duration

| Method | Description |
|--------|-------------|
| `Duration.from_nanoseconds(n)` | Create from nanoseconds |
| `Duration.from_microseconds(n)` | Create from microseconds |
| `Duration.from_milliseconds(n)` | Create from milliseconds |
| `Duration.from_seconds(n)` | Create from seconds |
| `Duration.from_minutes(n)` | Create from minutes |
| `Duration.from_hours(n)` | Create from hours |
| `Duration.from_days(n)` | Create from days |
| `d.to_nanoseconds()` | Convert to nanoseconds |
| `d.to_milliseconds()` | Convert to milliseconds |
| `d.to_seconds()` | Convert to seconds (float) |
| `d.to_minutes()` | Convert to minutes (float) |
| `d.to_hours()` | Convert to hours (float) |

### Formatting Functions

| Function | Example Output |
|----------|----------------|
| `format_iso8601(dt)` | `2025-12-28T14:30:45Z` |
| `format_rfc3339(dt)` | `2025-12-28T14:30:45.123456Z` |
| `format_rfc3339_millis(dt)` | `2025-12-28T14:30:45.123Z` |
| `format_date(dt)` | `2025-12-28` |
| `format_time(dt)` | `14:30:45` |
| `format_time_with_micros(dt)` | `14:30:45.123456` |

### Parsing Functions

| Function | Accepted Format |
|----------|-----------------|
| `parse_iso8601(s)` | ISO 8601 / RFC 3339 |
| `parse_date(s)` | `YYYY-MM-DD` |
| `parse_time(s)` | `HH:MM:SS[.microseconds]` |

### Clock

| Method | Description |
|--------|-------------|
| `Clock.monotonic_ns()` | Monotonic nanoseconds |
| `Clock.monotonic_ms()` | Monotonic milliseconds |
| `Clock.unix_timestamp()` | Unix seconds |
| `Clock.unix_timestamp_ms()` | Unix milliseconds |
| `Clock.unix_timestamp_ns()` | Unix nanoseconds |

## Building

```bash
pixi run build
pixi run test
pixi run format
```

## License

MIT
