"""
DateTime - Date and time representation.

Provides a DateTime struct for representing calendar dates and times
with microsecond precision. Supports creation, comparison, and arithmetic.

Example:
    var now = DateTime.now()
    print(now.year, now.month, now.day)

    var future = now.add_days(7)
    var diff = future.subtract(now)
    print("Difference:", diff.to_days(), "days")
"""

from python import Python
from .duration import Duration
from .timestamp import Timestamp


@value
struct DateTime(Stringable, EqualityComparable):
    """
    Represents a calendar date and time in UTC.

    All DateTime instances represent UTC time. For local time
    conversion, use the formatting functions.
    """

    var year: Int
    """Year (e.g., 2025)."""

    var month: Int
    """Month (1-12)."""

    var day: Int
    """Day of month (1-31)."""

    var hour: Int
    """Hour (0-23)."""

    var minute: Int
    """Minute (0-59)."""

    var second: Int
    """Second (0-59)."""

    var microsecond: Int
    """Microsecond (0-999999)."""

    # Days in each month (non-leap year)
    alias _DAYS_IN_MONTH = List[Int](0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
    alias _DAYS_BEFORE_MONTH = List[Int](0, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334)

    fn __init__(out self):
        """Create DateTime at Unix epoch (1970-01-01 00:00:00)."""
        self.year = 1970
        self.month = 1
        self.day = 1
        self.hour = 0
        self.minute = 0
        self.second = 0
        self.microsecond = 0

    fn __init__(
        out self,
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        microsecond: Int = 0,
    ):
        """
        Create DateTime from components.

        Args:
            year: Year (e.g., 2025).
            month: Month (1-12).
            day: Day of month (1-31).
            hour: Hour (0-23).
            minute: Minute (0-59).
            second: Second (0-59).
            microsecond: Microsecond (0-999999).
        """
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.microsecond = microsecond

    @staticmethod
    fn now() raises -> DateTime:
        """
        Get current UTC datetime.

        Returns:
            Current time as DateTime.
        """
        var datetime = Python.import_module("datetime")
        var utc_now = datetime.datetime.utcnow()
        return DateTime(
            int(utc_now.year),
            int(utc_now.month),
            int(utc_now.day),
            int(utc_now.hour),
            int(utc_now.minute),
            int(utc_now.second),
            int(utc_now.microsecond),
        )

    @staticmethod
    fn from_timestamp(ts: Timestamp) raises -> DateTime:
        """
        Create DateTime from Unix timestamp.

        Args:
            ts: Unix timestamp.

        Returns:
            DateTime in UTC.
        """
        var datetime = Python.import_module("datetime")
        var dt = datetime.datetime.utcfromtimestamp(ts.to_float_seconds())
        return DateTime(
            int(dt.year),
            int(dt.month),
            int(dt.day),
            int(dt.hour),
            int(dt.minute),
            int(dt.second),
            int(dt.microsecond),
        )

    @staticmethod
    fn from_timestamp_seconds(seconds: Int) raises -> DateTime:
        """
        Create DateTime from Unix timestamp in seconds.

        Args:
            seconds: Seconds since Unix epoch.

        Returns:
            DateTime in UTC.
        """
        return DateTime.from_timestamp(Timestamp.from_seconds(seconds))

    fn to_timestamp(self) raises -> Timestamp:
        """
        Convert to Unix timestamp.

        Returns:
            Unix timestamp.
        """
        var datetime = Python.import_module("datetime")
        var calendar = Python.import_module("calendar")
        var dt = datetime.datetime(
            self.year,
            self.month,
            self.day,
            self.hour,
            self.minute,
            self.second,
            self.microsecond,
        )
        var seconds = int(calendar.timegm(dt.timetuple()))
        var nanos = self.microsecond * 1000
        return Timestamp(seconds, nanos)

    fn to_unix_seconds(self) raises -> Int:
        """Get Unix timestamp in seconds."""
        return self.to_timestamp().seconds

    @staticmethod
    fn _is_leap_year(year: Int) -> Bool:
        """Check if year is a leap year."""
        return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

    @staticmethod
    fn _days_in_month(year: Int, month: Int) -> Int:
        """Get days in a specific month."""
        if month == 2 and DateTime._is_leap_year(year):
            return 29
        return DateTime._DAYS_IN_MONTH[month]

    fn is_leap_year(self) -> Bool:
        """Check if this datetime's year is a leap year."""
        return Self._is_leap_year(self.year)

    fn day_of_year(self) -> Int:
        """Get day of year (1-366)."""
        var days = Self._DAYS_BEFORE_MONTH[self.month] + self.day
        if self.month > 2 and self.is_leap_year():
            days += 1
        return days

    fn day_of_week(self) raises -> Int:
        """
        Get day of week (0=Monday, 6=Sunday).

        Uses Zeller's congruence for calculation.
        """
        var datetime = Python.import_module("datetime")
        var dt = datetime.datetime(self.year, self.month, self.day)
        return int(dt.weekday())

    fn weekday_name(self) raises -> String:
        """Get weekday name (Monday, Tuesday, etc.)."""
        var names = List[String](
            "Monday", "Tuesday", "Wednesday", "Thursday",
            "Friday", "Saturday", "Sunday"
        )
        return names[self.day_of_week()]

    fn month_name(self) -> String:
        """Get month name (January, February, etc.)."""
        var names = List[String](
            "", "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        )
        return names[self.month]

    fn add(self, duration: Duration) raises -> DateTime:
        """
        Add duration to datetime.

        Args:
            duration: Duration to add.

        Returns:
            New DateTime with duration added.
        """
        var ts = self.to_timestamp()
        var new_ts = Timestamp(
            ts.seconds + duration.seconds,
            ts.nanoseconds + duration.nanoseconds,
        )
        return DateTime.from_timestamp(new_ts)

    fn subtract(self, duration: Duration) raises -> DateTime:
        """
        Subtract duration from datetime.

        Args:
            duration: Duration to subtract.

        Returns:
            New DateTime with duration subtracted.
        """
        var ts = self.to_timestamp()
        var new_ts = Timestamp(
            ts.seconds - duration.seconds,
            ts.nanoseconds - duration.nanoseconds,
        )
        return DateTime.from_timestamp(new_ts)

    fn subtract(self, other: DateTime) raises -> Duration:
        """
        Get duration between two datetimes.

        Args:
            other: Other datetime.

        Returns:
            Duration between datetimes.
        """
        var ts1 = self.to_timestamp()
        var ts2 = other.to_timestamp()
        return Duration(
            ts1.seconds - ts2.seconds,
            ts1.nanoseconds - ts2.nanoseconds,
        )

    fn add_seconds(self, seconds: Int) raises -> DateTime:
        """Add seconds to datetime."""
        return self.add(Duration.from_seconds(seconds))

    fn add_minutes(self, minutes: Int) raises -> DateTime:
        """Add minutes to datetime."""
        return self.add(Duration.from_minutes(minutes))

    fn add_hours(self, hours: Int) raises -> DateTime:
        """Add hours to datetime."""
        return self.add(Duration.from_hours(hours))

    fn add_days(self, days: Int) raises -> DateTime:
        """Add days to datetime."""
        return self.add(Duration.from_days(days))

    fn start_of_day(self) -> DateTime:
        """Get datetime at start of day (00:00:00)."""
        return DateTime(self.year, self.month, self.day, 0, 0, 0, 0)

    fn end_of_day(self) -> DateTime:
        """Get datetime at end of day (23:59:59.999999)."""
        return DateTime(self.year, self.month, self.day, 23, 59, 59, 999999)

    fn start_of_month(self) -> DateTime:
        """Get datetime at start of month."""
        return DateTime(self.year, self.month, 1, 0, 0, 0, 0)

    fn end_of_month(self) -> DateTime:
        """Get datetime at end of month."""
        var last_day = Self._days_in_month(self.year, self.month)
        return DateTime(self.year, self.month, last_day, 23, 59, 59, 999999)

    fn start_of_year(self) -> DateTime:
        """Get datetime at start of year."""
        return DateTime(self.year, 1, 1, 0, 0, 0, 0)

    fn __eq__(self, other: DateTime) -> Bool:
        """Check equality."""
        return (
            self.year == other.year
            and self.month == other.month
            and self.day == other.day
            and self.hour == other.hour
            and self.minute == other.minute
            and self.second == other.second
            and self.microsecond == other.microsecond
        )

    fn __ne__(self, other: DateTime) -> Bool:
        """Check inequality."""
        return not self.__eq__(other)

    fn __lt__(self, other: DateTime) -> Bool:
        """Check if less than (earlier)."""
        if self.year != other.year:
            return self.year < other.year
        if self.month != other.month:
            return self.month < other.month
        if self.day != other.day:
            return self.day < other.day
        if self.hour != other.hour:
            return self.hour < other.hour
        if self.minute != other.minute:
            return self.minute < other.minute
        if self.second != other.second:
            return self.second < other.second
        return self.microsecond < other.microsecond

    fn __le__(self, other: DateTime) -> Bool:
        """Check if less than or equal."""
        return self.__lt__(other) or self.__eq__(other)

    fn __gt__(self, other: DateTime) -> Bool:
        """Check if greater than (later)."""
        return other.__lt__(self)

    fn __ge__(self, other: DateTime) -> Bool:
        """Check if greater than or equal."""
        return other.__le__(self)

    fn __str__(self) -> String:
        """Convert to ISO 8601 string format."""
        # Pad with zeros
        fn pad2(n: Int) -> String:
            if n < 10:
                return "0" + String(n)
            return String(n)

        fn pad4(n: Int) -> String:
            if n < 10:
                return "000" + String(n)
            elif n < 100:
                return "00" + String(n)
            elif n < 1000:
                return "0" + String(n)
            return String(n)

        fn pad6(n: Int) -> String:
            if n < 10:
                return "00000" + String(n)
            elif n < 100:
                return "0000" + String(n)
            elif n < 1000:
                return "000" + String(n)
            elif n < 10000:
                return "00" + String(n)
            elif n < 100000:
                return "0" + String(n)
            return String(n)

        return (
            pad4(self.year) + "-" + pad2(self.month) + "-" + pad2(self.day) + "T" +
            pad2(self.hour) + ":" + pad2(self.minute) + ":" + pad2(self.second) +
            "." + pad6(self.microsecond) + "Z"
        )


struct Date(Stringable, EqualityComparable):
    """
    Represents a calendar date without time component.

    Useful when only the date matters, not the time.
    """

    var year: Int
    """Year (e.g., 2025)."""

    var month: Int
    """Month (1-12)."""

    var day: Int
    """Day of month (1-31)."""

    fn __init__(out self, year: Int, month: Int, day: Int):
        """Create date from components."""
        self.year = year
        self.month = month
        self.day = day

    @staticmethod
    fn today() raises -> Date:
        """Get today's date in UTC."""
        var dt = DateTime.now()
        return Date(dt.year, dt.month, dt.day)

    @staticmethod
    fn from_datetime(dt: DateTime) -> Date:
        """Extract date from DateTime."""
        return Date(dt.year, dt.month, dt.day)

    fn to_datetime(self) -> DateTime:
        """Convert to DateTime at midnight."""
        return DateTime(self.year, self.month, self.day, 0, 0, 0, 0)

    fn __eq__(self, other: Date) -> Bool:
        """Check equality."""
        return self.year == other.year and self.month == other.month and self.day == other.day

    fn __ne__(self, other: Date) -> Bool:
        """Check inequality."""
        return not self.__eq__(other)

    fn __lt__(self, other: Date) -> Bool:
        """Check if less than."""
        if self.year != other.year:
            return self.year < other.year
        if self.month != other.month:
            return self.month < other.month
        return self.day < other.day

    fn __str__(self) -> String:
        """Convert to ISO 8601 date string."""
        fn pad2(n: Int) -> String:
            if n < 10:
                return "0" + String(n)
            return String(n)

        fn pad4(n: Int) -> String:
            if n < 10:
                return "000" + String(n)
            elif n < 100:
                return "00" + String(n)
            elif n < 1000:
                return "0" + String(n)
            return String(n)

        return pad4(self.year) + "-" + pad2(self.month) + "-" + pad2(self.day)


struct Time(Stringable, EqualityComparable):
    """
    Represents a time of day without date component.

    Useful for representing times that repeat daily.
    """

    var hour: Int
    """Hour (0-23)."""

    var minute: Int
    """Minute (0-59)."""

    var second: Int
    """Second (0-59)."""

    var microsecond: Int
    """Microsecond (0-999999)."""

    fn __init__(out self, hour: Int, minute: Int, second: Int = 0, microsecond: Int = 0):
        """Create time from components."""
        self.hour = hour
        self.minute = minute
        self.second = second
        self.microsecond = microsecond

    @staticmethod
    fn from_datetime(dt: DateTime) -> Time:
        """Extract time from DateTime."""
        return Time(dt.hour, dt.minute, dt.second, dt.microsecond)

    fn to_seconds_since_midnight(self) -> Int:
        """Get total seconds since midnight."""
        return self.hour * 3600 + self.minute * 60 + self.second

    fn __eq__(self, other: Time) -> Bool:
        """Check equality."""
        return (
            self.hour == other.hour
            and self.minute == other.minute
            and self.second == other.second
            and self.microsecond == other.microsecond
        )

    fn __ne__(self, other: Time) -> Bool:
        """Check inequality."""
        return not self.__eq__(other)

    fn __lt__(self, other: Time) -> Bool:
        """Check if less than."""
        if self.hour != other.hour:
            return self.hour < other.hour
        if self.minute != other.minute:
            return self.minute < other.minute
        if self.second != other.second:
            return self.second < other.second
        return self.microsecond < other.microsecond

    fn __str__(self) -> String:
        """Convert to ISO 8601 time string."""
        fn pad2(n: Int) -> String:
            if n < 10:
                return "0" + String(n)
            return String(n)

        fn pad6(n: Int) -> String:
            if n < 10:
                return "00000" + String(n)
            elif n < 100:
                return "0000" + String(n)
            elif n < 1000:
                return "000" + String(n)
            elif n < 10000:
                return "00" + String(n)
            elif n < 100000:
                return "0" + String(n)
            return String(n)

        return (
            pad2(self.hour) + ":" + pad2(self.minute) + ":" + pad2(self.second) +
            "." + pad6(self.microsecond)
        )
