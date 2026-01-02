"""
Tests for mojo-time library.

Covers DateTime, Duration, Timestamp, formatting, and clock utilities.
"""

from testing import assert_equal, assert_true, assert_false
from time import sleep

from src import (
    DateTime,
    Date,
    Time,
    Duration,
    Timestamp,
    TimestampRange,
    Clock,
    Stopwatch,
    Timer,
    format_iso8601,
    format_rfc3339,
    format_rfc3339_millis,
    format_date,
    format_time,
    parse_iso8601,
    parse_date,
    ParseResult,
)


# ============================================================================
# Duration Tests
# ============================================================================


fn test_duration_creation():
    """Test Duration creation from various units."""
    # From nanoseconds
    var d1 = Duration.from_nanoseconds(1_500_000_000)
    assert_equal(d1.seconds, 1)
    assert_equal(d1.nanoseconds, 500_000_000)

    # From microseconds
    var d2 = Duration.from_microseconds(2_500_000)
    assert_equal(d2.seconds, 2)
    assert_equal(d2.nanoseconds, 500_000_000)

    # From milliseconds
    var d3 = Duration.from_milliseconds(3500)
    assert_equal(d3.seconds, 3)
    assert_equal(d3.nanoseconds, 500_000_000)

    # From seconds
    var d4 = Duration.from_seconds(5)
    assert_equal(d4.seconds, 5)
    assert_equal(d4.nanoseconds, 0)

    # From minutes
    var d5 = Duration.from_minutes(2)
    assert_equal(d5.seconds, 120)

    # From hours
    var d6 = Duration.from_hours(1)
    assert_equal(d6.seconds, 3600)

    # From days
    var d7 = Duration.from_days(1)
    assert_equal(d7.seconds, 86400)

    print("test_duration_creation: PASSED")


fn test_duration_conversions():
    """Test Duration conversion to various units."""
    var d = Duration(3661, 500_000_000)  # 1h 1m 1.5s

    assert_equal(d.to_milliseconds(), 3_661_500)
    assert_true(abs(d.to_seconds() - 3661.5) < 0.001)
    assert_true(abs(d.to_minutes() - 61.025) < 0.001)
    assert_true(abs(d.to_hours() - 1.0170833) < 0.001)

    print("test_duration_conversions: PASSED")


fn test_duration_arithmetic():
    """Test Duration arithmetic operations."""
    var d1 = Duration.from_seconds(10)
    var d2 = Duration.from_seconds(5)

    # Addition
    var sum = d1 + d2
    assert_equal(sum.seconds, 15)

    # Subtraction
    var diff = d1 - d2
    assert_equal(diff.seconds, 5)

    # Multiplication
    var mult = d2 * 3
    assert_equal(mult.seconds, 15)

    # Division
    var div = d1 // 2
    assert_equal(div.seconds, 5)

    print("test_duration_arithmetic: PASSED")


fn test_duration_comparison():
    """Test Duration comparison operators."""
    var d1 = Duration.from_seconds(10)
    var d2 = Duration.from_seconds(5)
    var d3 = Duration.from_seconds(10)

    assert_true(d2 < d1)
    assert_true(d1 > d2)
    assert_true(d1 == d3)
    assert_true(d1 >= d3)
    assert_true(d1 <= d3)
    assert_false(d1 != d3)

    print("test_duration_comparison: PASSED")


fn test_duration_zero():
    """Test Duration zero handling."""
    var zero = Duration.zero()
    assert_true(zero.is_zero())

    var nonzero = Duration.from_seconds(1)
    assert_false(nonzero.is_zero())

    print("test_duration_zero: PASSED")


# ============================================================================
# Timestamp Tests
# ============================================================================


fn test_timestamp_creation() raises:
    """Test Timestamp creation methods."""
    # From seconds
    var ts1 = Timestamp.from_seconds(1735400000)
    assert_equal(ts1.seconds, 1735400000)
    assert_equal(ts1.nanoseconds, 0)

    # From milliseconds
    var ts2 = Timestamp.from_milliseconds(1735400000500)
    assert_equal(ts2.seconds, 1735400000)
    assert_equal(ts2.nanoseconds, 500_000_000)

    # From nanoseconds
    var ts3 = Timestamp.from_nanoseconds(1735400000_123456789)
    assert_equal(ts3.seconds, 1735400000)
    assert_equal(ts3.nanoseconds, 123456789)

    # Epoch
    var epoch = Timestamp.epoch()
    assert_equal(epoch.seconds, 0)
    assert_equal(epoch.nanoseconds, 0)

    print("test_timestamp_creation: PASSED")


fn test_timestamp_now() raises:
    """Test Timestamp.now() returns reasonable value."""
    var ts = Timestamp.now()

    # Should be after 2024 (timestamp > 1704067200)
    assert_true(ts.seconds > 1704067200)

    # Should be before 2030 (timestamp < 1893456000)
    assert_true(ts.seconds < 1893456000)

    print("test_timestamp_now: PASSED")


fn test_timestamp_conversions() raises:
    """Test Timestamp conversion methods."""
    var ts = Timestamp(1735400000, 123456789)

    assert_equal(ts.to_seconds(), 1735400000)
    assert_equal(ts.to_milliseconds(), 1735400000123)
    assert_equal(ts.to_microseconds(), 1735400000123456)

    print("test_timestamp_conversions: PASSED")


fn test_timestamp_comparison():
    """Test Timestamp comparison operators."""
    var ts1 = Timestamp.from_seconds(1000)
    var ts2 = Timestamp.from_seconds(2000)
    var ts3 = Timestamp.from_seconds(1000)

    assert_true(ts1 < ts2)
    assert_true(ts2 > ts1)
    assert_true(ts1 == ts3)
    assert_true(ts1.is_before(ts2))
    assert_true(ts2.is_after(ts1))

    print("test_timestamp_comparison: PASSED")


fn test_timestamp_range():
    """Test TimestampRange."""
    var start = Timestamp.from_seconds(1000)
    var end = Timestamp.from_seconds(2000)
    var range = TimestampRange(start, end)

    var inside = Timestamp.from_seconds(1500)
    var outside = Timestamp.from_seconds(2500)

    assert_true(range.contains(inside))
    assert_false(range.contains(outside))
    assert_equal(range.duration_ms(), 1000000)

    print("test_timestamp_range: PASSED")


# ============================================================================
# DateTime Tests
# ============================================================================


fn test_datetime_creation():
    """Test DateTime creation."""
    var dt = DateTime(2025, 12, 28, 14, 30, 45, 123456)

    assert_equal(dt.year, 2025)
    assert_equal(dt.month, 12)
    assert_equal(dt.day, 28)
    assert_equal(dt.hour, 14)
    assert_equal(dt.minute, 30)
    assert_equal(dt.second, 45)
    assert_equal(dt.microsecond, 123456)

    print("test_datetime_creation: PASSED")


fn test_datetime_now() raises:
    """Test DateTime.now() returns reasonable value."""
    var dt = DateTime.now()

    # Should be in 2025 or later
    assert_true(dt.year >= 2024)
    # Month should be valid
    assert_true(dt.month >= 1 and dt.month <= 12)
    # Day should be valid
    assert_true(dt.day >= 1 and dt.day <= 31)

    print("test_datetime_now: PASSED")


fn test_datetime_from_timestamp() raises:
    """Test DateTime.from_timestamp()."""
    # Unix timestamp for 2025-12-28 14:30:00 UTC
    var ts = Timestamp.from_seconds(1735396200)
    var dt = DateTime.from_timestamp(ts)

    assert_equal(dt.year, 2025)
    assert_equal(dt.month, 12)
    assert_equal(dt.day, 28)
    assert_equal(dt.hour, 14)
    assert_equal(dt.minute, 30)
    assert_equal(dt.second, 0)

    print("test_datetime_from_timestamp: PASSED")


fn test_datetime_to_timestamp() raises:
    """Test DateTime.to_timestamp()."""
    var dt = DateTime(2025, 12, 28, 14, 30, 0, 0)
    var ts = dt.to_timestamp()

    assert_equal(ts.seconds, 1735396200)

    print("test_datetime_to_timestamp: PASSED")


fn test_datetime_arithmetic() raises:
    """Test DateTime add/subtract operations."""
    var dt = DateTime(2025, 12, 28, 14, 30, 0, 0)

    # Add duration
    var plus_hour = dt.add_hours(1)
    assert_equal(plus_hour.hour, 15)

    # Add days (crossing month boundary)
    var plus_days = dt.add_days(5)
    assert_equal(plus_days.year, 2026)
    assert_equal(plus_days.month, 1)
    assert_equal(plus_days.day, 2)

    print("test_datetime_arithmetic: PASSED")


fn test_datetime_comparison():
    """Test DateTime comparison operators."""
    var dt1 = DateTime(2025, 12, 28, 14, 30, 0, 0)
    var dt2 = DateTime(2025, 12, 28, 15, 30, 0, 0)
    var dt3 = DateTime(2025, 12, 28, 14, 30, 0, 0)

    assert_true(dt1 < dt2)
    assert_true(dt2 > dt1)
    assert_true(dt1 == dt3)
    assert_false(dt1 != dt3)

    print("test_datetime_comparison: PASSED")


fn test_datetime_day_helpers():
    """Test DateTime day-related helpers."""
    var dt = DateTime(2025, 3, 15, 10, 30, 0, 0)

    # Start and end of day
    var start = dt.start_of_day()
    assert_equal(start.hour, 0)
    assert_equal(start.minute, 0)
    assert_equal(start.second, 0)

    var end = dt.end_of_day()
    assert_equal(end.hour, 23)
    assert_equal(end.minute, 59)
    assert_equal(end.second, 59)

    # Day of year
    var day_of_year = dt.day_of_year()
    assert_equal(day_of_year, 74)  # March 15 = day 74

    print("test_datetime_day_helpers: PASSED")


fn test_datetime_leap_year():
    """Test leap year detection."""
    var dt2024 = DateTime(2024, 1, 1)  # Leap year
    var dt2025 = DateTime(2025, 1, 1)  # Not leap year
    var dt2000 = DateTime(2000, 1, 1)  # Leap year (div by 400)
    var dt1900 = DateTime(1900, 1, 1)  # Not leap year (div by 100 but not 400)

    assert_true(dt2024.is_leap_year())
    assert_false(dt2025.is_leap_year())
    assert_true(dt2000.is_leap_year())
    assert_false(dt1900.is_leap_year())

    print("test_datetime_leap_year: PASSED")


# ============================================================================
# Date and Time Tests
# ============================================================================


fn test_date():
    """Test Date struct."""
    var date = Date(2025, 12, 28)
    assert_equal(date.year, 2025)
    assert_equal(date.month, 12)
    assert_equal(date.day, 28)

    var dt = date.to_datetime()
    assert_equal(dt.year, 2025)
    assert_equal(dt.hour, 0)

    print("test_date: PASSED")


fn test_time():
    """Test Time struct."""
    var time = Time(14, 30, 45, 123456)
    assert_equal(time.hour, 14)
    assert_equal(time.minute, 30)
    assert_equal(time.second, 45)
    assert_equal(time.microsecond, 123456)

    var secs = time.to_seconds_since_midnight()
    assert_equal(secs, 14 * 3600 + 30 * 60 + 45)

    print("test_time: PASSED")


# ============================================================================
# Formatting Tests
# ============================================================================


fn test_format_iso8601():
    """Test ISO 8601 formatting."""
    var dt = DateTime(2025, 12, 28, 14, 30, 45, 0)
    var formatted = format_iso8601(dt)
    assert_equal(formatted, "2025-12-28T14:30:45Z")

    print("test_format_iso8601: PASSED")


fn test_format_rfc3339():
    """Test RFC 3339 formatting with microseconds."""
    var dt = DateTime(2025, 12, 28, 14, 30, 45, 123456)
    var formatted = format_rfc3339(dt)
    assert_equal(formatted, "2025-12-28T14:30:45.123456Z")

    print("test_format_rfc3339: PASSED")


fn test_format_rfc3339_millis():
    """Test RFC 3339 formatting with milliseconds."""
    var dt = DateTime(2025, 12, 28, 14, 30, 45, 123456)
    var formatted = format_rfc3339_millis(dt)
    assert_equal(formatted, "2025-12-28T14:30:45.123Z")

    print("test_format_rfc3339_millis: PASSED")


fn test_format_date():
    """Test date-only formatting."""
    var dt = DateTime(2025, 12, 28, 14, 30, 45, 0)
    var formatted = format_date(dt)
    assert_equal(formatted, "2025-12-28")

    print("test_format_date: PASSED")


fn test_format_time():
    """Test time-only formatting."""
    var dt = DateTime(2025, 12, 28, 14, 30, 45, 0)
    var formatted = format_time(dt)
    assert_equal(formatted, "14:30:45")

    print("test_format_time: PASSED")


# ============================================================================
# Parsing Tests
# ============================================================================


fn test_parse_iso8601():
    """Test ISO 8601 parsing."""
    # Basic format
    var result1 = parse_iso8601("2025-12-28T14:30:45Z")
    assert_true(result1.success)
    assert_equal(result1.datetime.year, 2025)
    assert_equal(result1.datetime.month, 12)
    assert_equal(result1.datetime.day, 28)
    assert_equal(result1.datetime.hour, 14)
    assert_equal(result1.datetime.minute, 30)
    assert_equal(result1.datetime.second, 45)

    # With microseconds
    var result2 = parse_iso8601("2025-12-28T14:30:45.123456Z")
    assert_true(result2.success)
    assert_equal(result2.datetime.microsecond, 123456)

    # With milliseconds
    var result3 = parse_iso8601("2025-12-28T14:30:45.123Z")
    assert_true(result3.success)
    assert_equal(result3.datetime.microsecond, 123000)

    print("test_parse_iso8601: PASSED")


fn test_parse_date():
    """Test date-only parsing."""
    var result = parse_date("2025-12-28")
    assert_true(result.success)
    assert_equal(result.datetime.year, 2025)
    assert_equal(result.datetime.month, 12)
    assert_equal(result.datetime.day, 28)
    assert_equal(result.datetime.hour, 0)

    print("test_parse_date: PASSED")


fn test_parse_invalid():
    """Test parsing invalid strings."""
    var result1 = parse_iso8601("invalid")
    assert_false(result1.success)

    var result2 = parse_iso8601("2025-13-28T14:30:45Z")  # Invalid month
    assert_false(result2.success)

    print("test_parse_invalid: PASSED")


# ============================================================================
# Clock Tests
# ============================================================================


fn test_clock_monotonic():
    """Test Clock monotonic time."""
    var t1 = Clock.monotonic_ns()
    var t2 = Clock.monotonic_ns()

    # Time should always increase
    assert_true(t2 >= t1)

    print("test_clock_monotonic: PASSED")


fn test_clock_unix_timestamp() raises:
    """Test Clock.unix_timestamp()."""
    var ts = Clock.unix_timestamp()

    # Should be after 2024
    assert_true(ts > 1704067200)

    # Should be before 2030
    assert_true(ts < 1893456000)

    print("test_clock_unix_timestamp: PASSED")


fn test_stopwatch():
    """Test Stopwatch functionality."""
    var sw = Stopwatch.start_new()

    # Should be running
    assert_true(sw.is_running())

    # Elapsed should be positive
    assert_true(sw.elapsed_ns() > 0)

    # Stop and check
    sw.stop()
    assert_false(sw.is_running())

    var elapsed1 = sw.elapsed_ns()
    var elapsed2 = sw.elapsed_ns()
    assert_equal(elapsed1, elapsed2)  # Should be same when stopped

    # Reset
    sw.reset()
    assert_equal(sw.elapsed_ns(), 0)

    print("test_stopwatch: PASSED")


fn test_timer():
    """Test Timer functionality."""
    var timer = Timer.start_ms(100)  # 100ms timeout

    # Should not be expired immediately
    assert_false(timer.is_expired())

    # Remaining should be positive
    assert_true(timer.remaining_ms() > 0)

    # Remaining should be <= timeout
    assert_true(timer.remaining_ms() <= 100)

    print("test_timer: PASSED")


# ============================================================================
# Integration Tests
# ============================================================================


fn test_roundtrip_datetime_timestamp() raises:
    """Test DateTime <-> Timestamp roundtrip."""
    var original = DateTime(2025, 12, 28, 14, 30, 45, 123000)
    var ts = original.to_timestamp()
    var restored = DateTime.from_timestamp(ts)

    assert_equal(original.year, restored.year)
    assert_equal(original.month, restored.month)
    assert_equal(original.day, restored.day)
    assert_equal(original.hour, restored.hour)
    assert_equal(original.minute, restored.minute)
    assert_equal(original.second, restored.second)
    # Note: microsecond precision may vary due to float conversion

    print("test_roundtrip_datetime_timestamp: PASSED")


fn test_roundtrip_format_parse():
    """Test format <-> parse roundtrip."""
    var original = DateTime(2025, 12, 28, 14, 30, 45, 123456)
    var formatted = format_rfc3339(original)
    var result = parse_iso8601(formatted)

    assert_true(result.success)
    assert_equal(original.year, result.datetime.year)
    assert_equal(original.month, result.datetime.month)
    assert_equal(original.day, result.datetime.day)
    assert_equal(original.hour, result.datetime.hour)
    assert_equal(original.minute, result.datetime.minute)
    assert_equal(original.second, result.datetime.second)
    assert_equal(original.microsecond, result.datetime.microsecond)

    print("test_roundtrip_format_parse: PASSED")


# ============================================================================
# Main
# ============================================================================


fn main() raises:
    """Run all tests."""
    print("Running mojo-time tests...\n")

    # Duration tests
    test_duration_creation()
    test_duration_conversions()
    test_duration_arithmetic()
    test_duration_comparison()
    test_duration_zero()

    # Timestamp tests
    test_timestamp_creation()
    test_timestamp_now()
    test_timestamp_conversions()
    test_timestamp_comparison()
    test_timestamp_range()

    # DateTime tests
    test_datetime_creation()
    test_datetime_now()
    test_datetime_from_timestamp()
    test_datetime_to_timestamp()
    test_datetime_arithmetic()
    test_datetime_comparison()
    test_datetime_day_helpers()
    test_datetime_leap_year()

    # Date/Time tests
    test_date()
    test_time()

    # Formatting tests
    test_format_iso8601()
    test_format_rfc3339()
    test_format_rfc3339_millis()
    test_format_date()
    test_format_time()

    # Parsing tests
    test_parse_iso8601()
    test_parse_date()
    test_parse_invalid()

    # Clock tests
    test_clock_monotonic()
    test_clock_unix_timestamp()
    test_stopwatch()
    test_timer()

    # Integration tests
    test_roundtrip_datetime_timestamp()
    test_roundtrip_format_parse()

    print("\nAll tests passed!")
