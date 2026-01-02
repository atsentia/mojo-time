"""
Unix Timestamp Handling

Provides Timestamp struct for Unix epoch-based time representation.
Supports conversion to/from DateTime and various units.

Example:
    var ts = Timestamp.now()
    print("Unix time:", ts.seconds)

    var dt = ts.to_datetime()
    print("DateTime:", dt)

    var ts2 = Timestamp.from_datetime(dt)
    assert ts.seconds == ts2.seconds
"""

from python import Python


@value
struct Timestamp(Stringable, EqualityComparable):
    """
    Unix timestamp with nanosecond precision.

    Represents time as seconds and nanoseconds since Unix epoch
    (1970-01-01 00:00:00 UTC).
    """

    var seconds: Int
    """Seconds since Unix epoch."""

    var nanoseconds: Int
    """Nanoseconds component (0-999,999,999)."""

    # Constants
    alias NANOS_PER_SECOND: Int = 1_000_000_000
    alias MILLIS_PER_SECOND: Int = 1_000
    alias MICROS_PER_SECOND: Int = 1_000_000
    alias NANOS_PER_MILLI: Int = 1_000_000
    alias NANOS_PER_MICRO: Int = 1_000

    fn __init__(out self):
        """Create zero timestamp (Unix epoch)."""
        self.seconds = 0
        self.nanoseconds = 0

    fn __init__(out self, seconds: Int, nanoseconds: Int = 0):
        """
        Create timestamp from seconds and nanoseconds.

        Args:
            seconds: Seconds since epoch.
            nanoseconds: Nanoseconds (will be normalized).
        """
        # Normalize nanoseconds
        var extra_secs = nanoseconds // Self.NANOS_PER_SECOND
        var remaining_nanos = nanoseconds % Self.NANOS_PER_SECOND
        if remaining_nanos < 0:
            remaining_nanos += Self.NANOS_PER_SECOND
            extra_secs -= 1

        self.seconds = seconds + extra_secs
        self.nanoseconds = remaining_nanos

    @staticmethod
    fn now() raises -> Timestamp:
        """
        Get current timestamp.

        Returns:
            Current time as Unix timestamp.
        """
        var time = Python.import_module("time")
        var ns = int(time.time_ns())
        var secs = ns // Timestamp.NANOS_PER_SECOND
        var remaining = ns % Timestamp.NANOS_PER_SECOND
        return Timestamp(secs, remaining)

    @staticmethod
    fn from_seconds(seconds: Int) -> Timestamp:
        """Create timestamp from seconds."""
        return Timestamp(seconds, 0)

    @staticmethod
    fn from_milliseconds(millis: Int) -> Timestamp:
        """Create timestamp from milliseconds since epoch."""
        var secs = millis // Timestamp.MILLIS_PER_SECOND
        var remaining = (millis % Timestamp.MILLIS_PER_SECOND) * Timestamp.NANOS_PER_MILLI
        return Timestamp(secs, remaining)

    @staticmethod
    fn from_microseconds(micros: Int) -> Timestamp:
        """Create timestamp from microseconds since epoch."""
        var secs = micros // Timestamp.MICROS_PER_SECOND
        var remaining = (micros % Timestamp.MICROS_PER_SECOND) * Timestamp.NANOS_PER_MICRO
        return Timestamp(secs, remaining)

    @staticmethod
    fn from_nanoseconds(nanos: Int) -> Timestamp:
        """Create timestamp from nanoseconds since epoch."""
        var secs = nanos // Timestamp.NANOS_PER_SECOND
        var remaining = nanos % Timestamp.NANOS_PER_SECOND
        return Timestamp(secs, remaining)

    @staticmethod
    fn epoch() -> Timestamp:
        """Get Unix epoch timestamp (zero)."""
        return Timestamp(0, 0)

    fn to_seconds(self) -> Int:
        """Get timestamp as seconds (truncated)."""
        return self.seconds

    fn to_milliseconds(self) -> Int:
        """Get timestamp as milliseconds."""
        return self.seconds * Self.MILLIS_PER_SECOND + self.nanoseconds // Self.NANOS_PER_MILLI

    fn to_microseconds(self) -> Int:
        """Get timestamp as microseconds."""
        return self.seconds * Self.MICROS_PER_SECOND + self.nanoseconds // Self.NANOS_PER_MICRO

    fn to_nanoseconds(self) -> Int:
        """Get timestamp as nanoseconds."""
        return self.seconds * Self.NANOS_PER_SECOND + self.nanoseconds

    fn to_float_seconds(self) -> Float64:
        """Get timestamp as floating point seconds."""
        return Float64(self.seconds) + Float64(self.nanoseconds) / Float64(Self.NANOS_PER_SECOND)

    fn elapsed_since(self, earlier: Timestamp) -> Int:
        """
        Get milliseconds elapsed since earlier timestamp.

        Args:
            earlier: Earlier timestamp.

        Returns:
            Milliseconds between timestamps.
        """
        return self.to_milliseconds() - earlier.to_milliseconds()

    fn is_after(self, other: Timestamp) -> Bool:
        """Check if this timestamp is after another."""
        if self.seconds != other.seconds:
            return self.seconds > other.seconds
        return self.nanoseconds > other.nanoseconds

    fn is_before(self, other: Timestamp) -> Bool:
        """Check if this timestamp is before another."""
        return other.is_after(self)

    fn __eq__(self, other: Timestamp) -> Bool:
        """Check equality."""
        return self.seconds == other.seconds and self.nanoseconds == other.nanoseconds

    fn __ne__(self, other: Timestamp) -> Bool:
        """Check inequality."""
        return not self.__eq__(other)

    fn __lt__(self, other: Timestamp) -> Bool:
        """Check if less than."""
        return self.is_before(other)

    fn __le__(self, other: Timestamp) -> Bool:
        """Check if less than or equal."""
        return self.__lt__(other) or self.__eq__(other)

    fn __gt__(self, other: Timestamp) -> Bool:
        """Check if greater than."""
        return self.is_after(other)

    fn __ge__(self, other: Timestamp) -> Bool:
        """Check if greater than or equal."""
        return self.__gt__(other) or self.__eq__(other)

    fn __str__(self) -> String:
        """Convert to string representation."""
        if self.nanoseconds > 0:
            return String(self.seconds) + "." + String(self.nanoseconds)
        return String(self.seconds)


struct TimestampRange:
    """
    Represents a time range between two timestamps.

    Useful for checking if a timestamp falls within a period.
    """

    var start: Timestamp
    """Start of range (inclusive)."""

    var end: Timestamp
    """End of range (exclusive)."""

    fn __init__(out self, start: Timestamp, end: Timestamp):
        """Create timestamp range."""
        self.start = start
        self.end = end

    fn contains(self, ts: Timestamp) -> Bool:
        """Check if timestamp is within range [start, end)."""
        return ts >= self.start and ts < self.end

    fn duration_ms(self) -> Int:
        """Get duration of range in milliseconds."""
        return self.end.to_milliseconds() - self.start.to_milliseconds()

    fn overlaps(self, other: TimestampRange) -> Bool:
        """Check if this range overlaps with another."""
        return self.start < other.end and other.start < self.end
