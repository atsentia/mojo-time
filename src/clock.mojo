"""
System Clock Access

Provides access to system time sources:
- Monotonic clock: For measuring elapsed time (unaffected by system time changes)
- Wall clock: For real-world timestamps

Uses Mojo's time module for high-resolution timing and Python's datetime
for wall clock access until native system calls are available.

Example:
    # Measure elapsed time
    var start = Clock.monotonic_ns()
    do_work()
    var elapsed = Clock.monotonic_ns() - start
    print("Elapsed:", elapsed, "ns")

    # Get current Unix timestamp
    var now = Clock.unix_timestamp()
    print("Unix time:", now)
"""

from time import perf_counter_ns
from python import Python


struct Clock:
    """
    System clock access for timing and timestamps.

    Provides both monotonic time (for measurements) and wall clock
    time (for real-world timestamps).
    """

    @staticmethod
    fn monotonic_ns() -> Int:
        """
        Get monotonic time in nanoseconds.

        Returns a nanosecond timestamp that only increases, unaffected
        by system clock adjustments. Use for measuring durations.

        Returns:
            Nanoseconds since an arbitrary start point.
        """
        return perf_counter_ns()

    @staticmethod
    fn monotonic_us() -> Int:
        """
        Get monotonic time in microseconds.

        Returns:
            Microseconds since an arbitrary start point.
        """
        return perf_counter_ns() // 1_000

    @staticmethod
    fn monotonic_ms() -> Int:
        """
        Get monotonic time in milliseconds.

        Returns:
            Milliseconds since an arbitrary start point.
        """
        return perf_counter_ns() // 1_000_000

    @staticmethod
    fn monotonic_seconds() -> Float64:
        """
        Get monotonic time in seconds.

        Returns:
            Seconds since an arbitrary start point.
        """
        return Float64(perf_counter_ns()) / 1_000_000_000.0

    @staticmethod
    fn unix_timestamp() raises -> Int:
        """
        Get current Unix timestamp in seconds.

        Returns:
            Seconds since Unix epoch (1970-01-01 00:00:00 UTC).
        """
        var time = Python.import_module("time")
        return int(time.time())

    @staticmethod
    fn unix_timestamp_ms() raises -> Int:
        """
        Get current Unix timestamp in milliseconds.

        Returns:
            Milliseconds since Unix epoch.
        """
        var time = Python.import_module("time")
        return int(time.time() * 1000)

    @staticmethod
    fn unix_timestamp_us() raises -> Int:
        """
        Get current Unix timestamp in microseconds.

        Returns:
            Microseconds since Unix epoch.
        """
        var time = Python.import_module("time")
        return int(time.time() * 1_000_000)

    @staticmethod
    fn unix_timestamp_ns() raises -> Int:
        """
        Get current Unix timestamp in nanoseconds.

        Returns:
            Nanoseconds since Unix epoch.
        """
        var time = Python.import_module("time")
        return int(time.time_ns())


struct Stopwatch:
    """
    Simple stopwatch for measuring elapsed time.

    Example:
        var sw = Stopwatch()
        sw.start()
        do_work()
        var elapsed = sw.elapsed_ms()
        print("Took", elapsed, "ms")
    """

    var _start_ns: Int
    """Start timestamp in nanoseconds."""

    var _running: Bool
    """Whether stopwatch is currently running."""

    var _accumulated_ns: Int
    """Accumulated time from previous start/stop cycles."""

    fn __init__(out self):
        """Create stopped stopwatch."""
        self._start_ns = 0
        self._running = False
        self._accumulated_ns = 0

    @staticmethod
    fn start_new() -> Stopwatch:
        """Create and start a new stopwatch."""
        var sw = Stopwatch()
        sw.start()
        return sw

    fn start(inout self):
        """Start or resume the stopwatch."""
        if not self._running:
            self._start_ns = perf_counter_ns()
            self._running = True

    fn stop(inout self):
        """Stop the stopwatch, preserving elapsed time."""
        if self._running:
            self._accumulated_ns += perf_counter_ns() - self._start_ns
            self._running = False

    fn reset(inout self):
        """Reset stopwatch to zero and stop."""
        self._start_ns = 0
        self._running = False
        self._accumulated_ns = 0

    fn restart(inout self):
        """Reset and start stopwatch."""
        self._accumulated_ns = 0
        self._start_ns = perf_counter_ns()
        self._running = True

    fn elapsed_ns(self) -> Int:
        """Get elapsed time in nanoseconds."""
        if self._running:
            return self._accumulated_ns + (perf_counter_ns() - self._start_ns)
        return self._accumulated_ns

    fn elapsed_us(self) -> Int:
        """Get elapsed time in microseconds."""
        return self.elapsed_ns() // 1_000

    fn elapsed_ms(self) -> Int:
        """Get elapsed time in milliseconds."""
        return self.elapsed_ns() // 1_000_000

    fn elapsed_seconds(self) -> Float64:
        """Get elapsed time in seconds."""
        return Float64(self.elapsed_ns()) / 1_000_000_000.0

    fn is_running(self) -> Bool:
        """Check if stopwatch is running."""
        return self._running


struct Timer:
    """
    Countdown timer for deadlines.

    Example:
        var timer = Timer.start(timeout_ms=5000)

        while not timer.is_expired():
            if try_operation():
                break
            sleep(100)

        if timer.is_expired():
            raise TimeoutError()
    """

    var _deadline_ns: Int
    """Deadline timestamp in nanoseconds (monotonic)."""

    var _timeout_ns: Int
    """Original timeout in nanoseconds."""

    fn __init__(out self, timeout_ns: Int):
        """
        Create timer with timeout in nanoseconds.

        Args:
            timeout_ns: Timeout duration in nanoseconds.
        """
        self._timeout_ns = timeout_ns
        self._deadline_ns = perf_counter_ns() + timeout_ns

    @staticmethod
    fn start(timeout_ns: Int) -> Timer:
        """Create and start timer with nanosecond timeout."""
        return Timer(timeout_ns)

    @staticmethod
    fn start_ms(timeout_ms: Int) -> Timer:
        """Create and start timer with millisecond timeout."""
        return Timer(timeout_ms * 1_000_000)

    @staticmethod
    fn start_seconds(timeout_seconds: Int) -> Timer:
        """Create and start timer with second timeout."""
        return Timer(timeout_seconds * 1_000_000_000)

    fn is_expired(self) -> Bool:
        """Check if timer has expired."""
        return perf_counter_ns() >= self._deadline_ns

    fn remaining_ns(self) -> Int:
        """Get remaining time in nanoseconds (0 if expired)."""
        var remaining = self._deadline_ns - perf_counter_ns()
        return max(0, remaining)

    fn remaining_ms(self) -> Int:
        """Get remaining time in milliseconds (0 if expired)."""
        return self.remaining_ns() // 1_000_000

    fn remaining_seconds(self) -> Float64:
        """Get remaining time in seconds (0 if expired)."""
        return Float64(self.remaining_ns()) / 1_000_000_000.0

    fn elapsed_ns(self) -> Int:
        """Get elapsed time since timer started."""
        return self._timeout_ns - self.remaining_ns()

    fn elapsed_ms(self) -> Int:
        """Get elapsed time in milliseconds."""
        return self.elapsed_ns() // 1_000_000

    fn reset(inout self):
        """Reset timer with same timeout."""
        self._deadline_ns = perf_counter_ns() + self._timeout_ns

    fn extend(inout self, additional_ns: Int):
        """Extend deadline by additional nanoseconds."""
        self._deadline_ns += additional_ns

    fn extend_ms(inout self, additional_ms: Int):
        """Extend deadline by additional milliseconds."""
        self._deadline_ns += additional_ms * 1_000_000
