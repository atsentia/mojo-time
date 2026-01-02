"""
DateTime Formatting and Parsing

Provides ISO 8601 and RFC 3339 formatting and parsing for DateTime.

Formats:
- ISO 8601 basic: "2025-12-28T14:30:00Z"
- RFC 3339 full: "2025-12-28T14:30:00.123456Z"
- Date only: "2025-12-28"
- Time only: "14:30:00"

Example:
    var dt = DateTime.now()
    var iso = format_iso8601(dt)
    var rfc = format_rfc3339(dt)

    var parsed = parse_iso8601(iso)
"""

from .datetime import DateTime, Date, Time


fn format_iso8601(dt: DateTime) -> String:
    """
    Format DateTime as ISO 8601 string.

    Format: "2025-12-28T14:30:00Z"

    Args:
        dt: DateTime to format.

    Returns:
        ISO 8601 formatted string.
    """
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

    return (
        pad4(dt.year) + "-" + pad2(dt.month) + "-" + pad2(dt.day) + "T" +
        pad2(dt.hour) + ":" + pad2(dt.minute) + ":" + pad2(dt.second) + "Z"
    )


fn format_rfc3339(dt: DateTime) -> String:
    """
    Format DateTime as RFC 3339 string with microseconds.

    Format: "2025-12-28T14:30:00.123456Z"

    Args:
        dt: DateTime to format.

    Returns:
        RFC 3339 formatted string with microseconds.
    """
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
        pad4(dt.year) + "-" + pad2(dt.month) + "-" + pad2(dt.day) + "T" +
        pad2(dt.hour) + ":" + pad2(dt.minute) + ":" + pad2(dt.second) +
        "." + pad6(dt.microsecond) + "Z"
    )


fn format_rfc3339_millis(dt: DateTime) -> String:
    """
    Format DateTime as RFC 3339 string with milliseconds.

    Format: "2025-12-28T14:30:00.123Z"

    Args:
        dt: DateTime to format.

    Returns:
        RFC 3339 formatted string with milliseconds.
    """
    fn pad2(n: Int) -> String:
        if n < 10:
            return "0" + String(n)
        return String(n)

    fn pad3(n: Int) -> String:
        if n < 10:
            return "00" + String(n)
        elif n < 100:
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

    var millis = dt.microsecond // 1000

    return (
        pad4(dt.year) + "-" + pad2(dt.month) + "-" + pad2(dt.day) + "T" +
        pad2(dt.hour) + ":" + pad2(dt.minute) + ":" + pad2(dt.second) +
        "." + pad3(millis) + "Z"
    )


fn format_date(dt: DateTime) -> String:
    """
    Format DateTime as date-only string.

    Format: "2025-12-28"

    Args:
        dt: DateTime to format.

    Returns:
        Date string.
    """
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

    return pad4(dt.year) + "-" + pad2(dt.month) + "-" + pad2(dt.day)


fn format_time(dt: DateTime) -> String:
    """
    Format DateTime as time-only string.

    Format: "14:30:00"

    Args:
        dt: DateTime to format.

    Returns:
        Time string.
    """
    fn pad2(n: Int) -> String:
        if n < 10:
            return "0" + String(n)
        return String(n)

    return pad2(dt.hour) + ":" + pad2(dt.minute) + ":" + pad2(dt.second)


fn format_time_with_micros(dt: DateTime) -> String:
    """
    Format DateTime as time string with microseconds.

    Format: "14:30:00.123456"

    Args:
        dt: DateTime to format.

    Returns:
        Time string with microseconds.
    """
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
        pad2(dt.hour) + ":" + pad2(dt.minute) + ":" + pad2(dt.second) +
        "." + pad6(dt.microsecond)
    )


fn format_unix_timestamp(dt: DateTime) raises -> String:
    """
    Format DateTime as Unix timestamp string.

    Args:
        dt: DateTime to format.

    Returns:
        Unix timestamp as string.
    """
    var ts = dt.to_timestamp()
    return String(ts.seconds)


fn format_human_readable(dt: DateTime) raises -> String:
    """
    Format DateTime as human-readable string.

    Format: "December 28, 2025 at 14:30"

    Args:
        dt: DateTime to format.

    Returns:
        Human-readable string.
    """
    fn pad2(n: Int) -> String:
        if n < 10:
            return "0" + String(n)
        return String(n)

    return (
        dt.month_name() + " " + String(dt.day) + ", " + String(dt.year) +
        " at " + pad2(dt.hour) + ":" + pad2(dt.minute)
    )


struct ParseResult:
    """Result of parsing a datetime string."""

    var datetime: DateTime
    """Parsed DateTime (valid if success is True)."""

    var success: Bool
    """Whether parsing succeeded."""

    var error: String
    """Error message if parsing failed."""

    fn __init__(out self, datetime: DateTime):
        """Create successful result."""
        self.datetime = datetime
        self.success = True
        self.error = ""

    fn __init__(out self, error: String):
        """Create failed result."""
        self.datetime = DateTime()
        self.success = False
        self.error = error


fn parse_iso8601(s: String) -> ParseResult:
    """
    Parse ISO 8601 / RFC 3339 datetime string.

    Accepts formats:
    - "2025-12-28T14:30:00Z"
    - "2025-12-28T14:30:00.123456Z"
    - "2025-12-28T14:30:00+00:00"
    - "2025-12-28"

    Args:
        s: String to parse.

    Returns:
        ParseResult with DateTime or error.
    """
    var length = len(s)

    # Minimum valid date: "2025-12-28" = 10 chars
    if length < 10:
        return ParseResult("String too short for datetime")

    # Parse year
    var year_str = s[0:4]
    var year = _parse_int(year_str)
    if year < 0:
        return ParseResult("Invalid year: " + year_str)

    if s[4] != "-":
        return ParseResult("Expected '-' at position 4")

    # Parse month
    var month_str = s[5:7]
    var month = _parse_int(month_str)
    if month < 1 or month > 12:
        return ParseResult("Invalid month: " + month_str)

    if s[7] != "-":
        return ParseResult("Expected '-' at position 7")

    # Parse day
    var day_str = s[8:10]
    var day = _parse_int(day_str)
    if day < 1 or day > 31:
        return ParseResult("Invalid day: " + day_str)

    # Date-only format
    if length == 10:
        return ParseResult(DateTime(year, month, day))

    # Expect 'T' separator
    if s[10] != "T":
        return ParseResult("Expected 'T' at position 10")

    # Minimum with time: "2025-12-28T14:30:00" = 19 chars
    if length < 19:
        return ParseResult("String too short for time component")

    # Parse hour
    var hour_str = s[11:13]
    var hour = _parse_int(hour_str)
    if hour < 0 or hour > 23:
        return ParseResult("Invalid hour: " + hour_str)

    if s[13] != ":":
        return ParseResult("Expected ':' at position 13")

    # Parse minute
    var minute_str = s[14:16]
    var minute = _parse_int(minute_str)
    if minute < 0 or minute > 59:
        return ParseResult("Invalid minute: " + minute_str)

    if s[16] != ":":
        return ParseResult("Expected ':' at position 16")

    # Parse second
    var second_str = s[17:19]
    var second = _parse_int(second_str)
    if second < 0 or second > 59:
        return ParseResult("Invalid second: " + second_str)

    var microsecond = 0

    # Check for fractional seconds
    if length > 19 and s[19] == ".":
        # Find end of fractional part (before Z or +/-)
        var frac_end = 20
        while frac_end < length:
            var c = s[frac_end]
            if c == "Z" or c == "+" or c == "-":
                break
            frac_end += 1

        var frac_str = s[20:frac_end]
        var frac_len = len(frac_str)

        if frac_len > 0:
            var frac_val = _parse_int(frac_str)
            if frac_val >= 0:
                # Normalize to microseconds
                if frac_len == 3:  # milliseconds
                    microsecond = frac_val * 1000
                elif frac_len == 6:  # microseconds
                    microsecond = frac_val
                elif frac_len < 6:
                    # Pad with zeros
                    var multiplier = 1
                    for _ in range(6 - frac_len):
                        multiplier *= 10
                    microsecond = frac_val * multiplier
                else:
                    # Truncate to microseconds
                    var divisor = 1
                    for _ in range(frac_len - 6):
                        divisor *= 10
                    microsecond = frac_val // divisor

    return ParseResult(DateTime(year, month, day, hour, minute, second, microsecond))


fn parse_date(s: String) -> ParseResult:
    """
    Parse date-only string.

    Format: "2025-12-28"

    Args:
        s: String to parse.

    Returns:
        ParseResult with DateTime (time components set to 0).
    """
    if len(s) != 10:
        return ParseResult("Invalid date format, expected YYYY-MM-DD")

    return parse_iso8601(s)


fn parse_time(s: String) -> ParseResult:
    """
    Parse time-only string.

    Format: "14:30:00" or "14:30:00.123456"

    Args:
        s: String to parse.

    Returns:
        ParseResult with DateTime (date set to 1970-01-01).
    """
    if len(s) < 8:
        return ParseResult("Invalid time format, expected HH:MM:SS")

    # Prepend date and parse as full datetime
    var full = "1970-01-01T" + s
    if not s.endswith("Z"):
        full = full + "Z"

    return parse_iso8601(full)


fn _parse_int(s: String) -> Int:
    """
    Parse string to integer.

    Returns -1 if parsing fails.
    """
    var result = 0
    for i in range(len(s)):
        var c = ord(s[i])
        if c < ord("0") or c > ord("9"):
            return -1
        result = result * 10 + (c - ord("0"))
    return result


struct DateTimeFormatter:
    """
    Configurable datetime formatter.

    Provides flexible formatting with custom patterns.
    """

    var include_microseconds: Bool
    """Whether to include microseconds in output."""

    var include_timezone: Bool
    """Whether to include 'Z' timezone suffix."""

    var date_separator: String
    """Separator between date components (default '-')."""

    var time_separator: String
    """Separator between time components (default ':')."""

    var datetime_separator: String
    """Separator between date and time (default 'T')."""

    fn __init__(out self):
        """Create formatter with default settings."""
        self.include_microseconds = True
        self.include_timezone = True
        self.date_separator = "-"
        self.time_separator = ":"
        self.datetime_separator = "T"

    fn format(self, dt: DateTime) -> String:
        """
        Format DateTime using current settings.

        Args:
            dt: DateTime to format.

        Returns:
            Formatted string.
        """
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

        var result = (
            pad4(dt.year) + self.date_separator +
            pad2(dt.month) + self.date_separator +
            pad2(dt.day) + self.datetime_separator +
            pad2(dt.hour) + self.time_separator +
            pad2(dt.minute) + self.time_separator +
            pad2(dt.second)
        )

        if self.include_microseconds and dt.microsecond > 0:
            result = result + "." + pad6(dt.microsecond)

        if self.include_timezone:
            result = result + "Z"

        return result
