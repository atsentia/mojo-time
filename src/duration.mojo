"""
Duration - Time interval representation.

Provides a Duration struct for representing time intervals with
nanosecond precision. Supports arithmetic operations and conversions.

Example:
    var d1 = Duration.from_seconds(30)
    var d2 = Duration.from_milliseconds(500)
    var total = d1 + d2  # 30.5 seconds

    print(total.to_seconds())      # 30.5
    print(total.to_milliseconds()) # 30500
"""


@value
struct Duration(Stringable, EqualityComparable):
    """
    Represents a time duration with nanosecond precision.

    Internally stores seconds and nanoseconds separately to avoid
    overflow for large durations while maintaining precision.
    """

    var seconds: Int
    """Whole seconds component."""

    var nanoseconds: Int
    """Nanoseconds component (0-999,999,999)."""

    # Constants for conversions
    alias NANOS_PER_SECOND: Int = 1_000_000_000
    alias NANOS_PER_MILLI: Int = 1_000_000
    alias NANOS_PER_MICRO: Int = 1_000
    alias MILLIS_PER_SECOND: Int = 1_000
    alias MICROS_PER_SECOND: Int = 1_000_000
    alias SECONDS_PER_MINUTE: Int = 60
    alias SECONDS_PER_HOUR: Int = 3600
    alias SECONDS_PER_DAY: Int = 86400

    fn __init__(out self):
        """Create zero duration."""
        self.seconds = 0
        self.nanoseconds = 0

    fn __init__(out self, seconds: Int, nanoseconds: Int = 0):
        """
        Create duration from seconds and nanoseconds.

        Args:
            seconds: Whole seconds.
            nanoseconds: Nanoseconds (will be normalized).
        """
        # Normalize nanoseconds to 0-999,999,999 range
        var total_nanos = nanoseconds
        var extra_seconds = total_nanos // Self.NANOS_PER_SECOND
        var remaining_nanos = total_nanos % Self.NANOS_PER_SECOND

        # Handle negative nanoseconds
        if remaining_nanos < 0:
            remaining_nanos += Self.NANOS_PER_SECOND
            extra_seconds -= 1

        self.seconds = seconds + extra_seconds
        self.nanoseconds = remaining_nanos

    @staticmethod
    fn zero() -> Duration:
        """Create zero duration."""
        return Duration(0, 0)

    @staticmethod
    fn from_nanoseconds(nanos: Int) -> Duration:
        """Create duration from nanoseconds."""
        var secs = nanos // Duration.NANOS_PER_SECOND
        var remaining = nanos % Duration.NANOS_PER_SECOND
        if remaining < 0:
            remaining += Duration.NANOS_PER_SECOND
            secs -= 1
        return Duration(secs, remaining)

    @staticmethod
    fn from_microseconds(micros: Int) -> Duration:
        """Create duration from microseconds."""
        var nanos = micros * Duration.NANOS_PER_MICRO
        return Duration.from_nanoseconds(nanos)

    @staticmethod
    fn from_milliseconds(millis: Int) -> Duration:
        """Create duration from milliseconds."""
        var secs = millis // Duration.MILLIS_PER_SECOND
        var remaining_millis = millis % Duration.MILLIS_PER_SECOND
        return Duration(secs, remaining_millis * Duration.NANOS_PER_MILLI)

    @staticmethod
    fn from_seconds(secs: Int) -> Duration:
        """Create duration from seconds."""
        return Duration(secs, 0)

    @staticmethod
    fn from_seconds_f64(secs: Float64) -> Duration:
        """Create duration from floating point seconds."""
        var whole_secs = Int(secs)
        var frac = secs - Float64(whole_secs)
        var nanos = Int(frac * Float64(Duration.NANOS_PER_SECOND))
        return Duration(whole_secs, nanos)

    @staticmethod
    fn from_minutes(minutes: Int) -> Duration:
        """Create duration from minutes."""
        return Duration(minutes * Duration.SECONDS_PER_MINUTE, 0)

    @staticmethod
    fn from_hours(hours: Int) -> Duration:
        """Create duration from hours."""
        return Duration(hours * Duration.SECONDS_PER_HOUR, 0)

    @staticmethod
    fn from_days(days: Int) -> Duration:
        """Create duration from days."""
        return Duration(days * Duration.SECONDS_PER_DAY, 0)

    fn to_nanoseconds(self) -> Int:
        """Convert duration to total nanoseconds."""
        return self.seconds * Self.NANOS_PER_SECOND + self.nanoseconds

    fn to_microseconds(self) -> Int:
        """Convert duration to total microseconds."""
        return self.seconds * Self.MICROS_PER_SECOND + self.nanoseconds // Self.NANOS_PER_MICRO

    fn to_milliseconds(self) -> Int:
        """Convert duration to total milliseconds."""
        return self.seconds * Self.MILLIS_PER_SECOND + self.nanoseconds // Self.NANOS_PER_MILLI

    fn to_seconds(self) -> Float64:
        """Convert duration to seconds as floating point."""
        return Float64(self.seconds) + Float64(self.nanoseconds) / Float64(Self.NANOS_PER_SECOND)

    fn to_minutes(self) -> Float64:
        """Convert duration to minutes as floating point."""
        return self.to_seconds() / Float64(Self.SECONDS_PER_MINUTE)

    fn to_hours(self) -> Float64:
        """Convert duration to hours as floating point."""
        return self.to_seconds() / Float64(Self.SECONDS_PER_HOUR)

    fn to_days(self) -> Float64:
        """Convert duration to days as floating point."""
        return self.to_seconds() / Float64(Self.SECONDS_PER_DAY)

    fn is_zero(self) -> Bool:
        """Check if duration is zero."""
        return self.seconds == 0 and self.nanoseconds == 0

    fn is_negative(self) -> Bool:
        """Check if duration is negative."""
        return self.seconds < 0

    fn abs(self) -> Duration:
        """Get absolute value of duration."""
        if self.seconds < 0:
            return Duration(-self.seconds, self.nanoseconds)
        return self

    fn __add__(self, other: Duration) -> Duration:
        """Add two durations."""
        var nanos = self.nanoseconds + other.nanoseconds
        var extra_secs = nanos // Self.NANOS_PER_SECOND
        nanos = nanos % Self.NANOS_PER_SECOND
        return Duration(self.seconds + other.seconds + extra_secs, nanos)

    fn __sub__(self, other: Duration) -> Duration:
        """Subtract duration from this duration."""
        var total_nanos = (
            (self.seconds - other.seconds) * Self.NANOS_PER_SECOND
            + (self.nanoseconds - other.nanoseconds)
        )
        return Duration.from_nanoseconds(total_nanos)

    fn __mul__(self, factor: Int) -> Duration:
        """Multiply duration by integer factor."""
        var total_nanos = self.to_nanoseconds() * factor
        return Duration.from_nanoseconds(total_nanos)

    fn __floordiv__(self, divisor: Int) -> Duration:
        """Divide duration by integer divisor."""
        var total_nanos = self.to_nanoseconds() // divisor
        return Duration.from_nanoseconds(total_nanos)

    fn __neg__(self) -> Duration:
        """Negate duration."""
        return Duration(-self.seconds, -self.nanoseconds)

    fn __eq__(self, other: Duration) -> Bool:
        """Check equality."""
        return self.seconds == other.seconds and self.nanoseconds == other.nanoseconds

    fn __ne__(self, other: Duration) -> Bool:
        """Check inequality."""
        return not self.__eq__(other)

    fn __lt__(self, other: Duration) -> Bool:
        """Check if less than."""
        if self.seconds != other.seconds:
            return self.seconds < other.seconds
        return self.nanoseconds < other.nanoseconds

    fn __le__(self, other: Duration) -> Bool:
        """Check if less than or equal."""
        return self.__lt__(other) or self.__eq__(other)

    fn __gt__(self, other: Duration) -> Bool:
        """Check if greater than."""
        return other.__lt__(self)

    fn __ge__(self, other: Duration) -> Bool:
        """Check if greater than or equal."""
        return other.__le__(self)

    fn __str__(self) -> String:
        """
        Convert to human-readable string.

        Returns:
            String like "1h30m15.5s" or "500ms" or "100us".
        """
        if self.is_zero():
            return "0s"

        var parts = List[String]()
        var secs = self.seconds
        var nanos = self.nanoseconds

        # Handle negative
        var negative = secs < 0
        if negative:
            secs = -secs

        # Days
        if secs >= Self.SECONDS_PER_DAY:
            var days = secs // Self.SECONDS_PER_DAY
            secs = secs % Self.SECONDS_PER_DAY
            parts.append(String(days) + "d")

        # Hours
        if secs >= Self.SECONDS_PER_HOUR:
            var hours = secs // Self.SECONDS_PER_HOUR
            secs = secs % Self.SECONDS_PER_HOUR
            parts.append(String(hours) + "h")

        # Minutes
        if secs >= Self.SECONDS_PER_MINUTE:
            var minutes = secs // Self.SECONDS_PER_MINUTE
            secs = secs % Self.SECONDS_PER_MINUTE
            parts.append(String(minutes) + "m")

        # Seconds with fractional part
        if secs > 0 or nanos > 0:
            if nanos > 0:
                var frac = Float64(nanos) / Float64(Self.NANOS_PER_SECOND)
                var total = Float64(secs) + frac
                parts.append(String(total) + "s")
            else:
                parts.append(String(secs) + "s")

        var result = String("")
        if negative:
            result = "-"
        for part in parts:
            result += part[]

        return result
