"""Exercise the real shell scripts without root or access to the system bus."""

import fcntl
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPTS = Path(__file__).resolve().parents[1] / "modules/remote-desktop-login"


class DesktopLoginTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.state = self.root / "state"
        self.state.mkdir(mode=0o700)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.uptime = self.root / "uptime"
        self.uptime.write_text("1000.25 500.00\n")
        self.calls = self.root / "restart"
        self.env = {
            **os.environ,
            "PATH": f"{self.bin}:{os.environ['PATH']}",
            "DESKTOP_LOGIN_STATE_DIR": str(self.state),
            "DESKTOP_LOGIN_UPTIME_FILE": str(self.uptime),
            "GREETD": str(self.bin / "greetd"),
            "NORMAL_CONFIG": "/normal.toml",
            "REMOTE_CONFIG": "/on-demand.toml",
            "TEST_ROOT": str(self.root),
            "TEST_UID": "0",
            "TEST_SESSIONS": "1 1000 alice seat0 200 user - no -\n",
            "TEST_SESSION_TYPE": "tty",
        }
        self.executable("id", 'import os; print(os.environ["TEST_UID"])')
        self.executable("greetd", """
import os, pathlib, sys
assert not (pathlib.Path(os.environ['DESKTOP_LOGIN_STATE_DIR']) / 'request').exists()
print(' '.join(sys.argv[1:]))
""")
        self.executable("loginctl", """
import os, sys
if sys.argv[1:] == ['list-sessions', '--no-legend', '--no-pager']:
    if os.environ.get('TEST_LIST_FAIL'):
        sys.exit(1)
    print(os.environ['TEST_SESSIONS'], end='')
elif (len(sys.argv) == 5 and sys.argv[1] == 'show-session'
      and sys.argv[3:] == ['--property=Type', '--value']):
    if os.environ.get('TEST_SHOW_FAIL'):
        sys.exit(1)
    print(os.environ['TEST_SESSION_TYPE'])
else:
    sys.exit('Unexpected loginctl arguments: ' + repr(sys.argv))
""")
        self.executable("systemctl", """
import os, pathlib, stat, sys
assert sys.argv[1:] == ['restart', 'greetd.service']
state = pathlib.Path(os.environ['DESKTOP_LOGIN_STATE_DIR'])
request = state / 'request'
(pathlib.Path(os.environ['TEST_ROOT']) / 'restart').write_text(
    request.read_text().strip() + '\\n' + oct(stat.S_IMODE(request.stat().st_mode)))
sys.exit(1 if os.environ.get('TEST_RESTART_FAIL') else 0)
""")

    def executable(self, name, code):
        path = self.bin / name
        path.write_text(f"#!{sys.executable}\n{code}\n")
        path.chmod(0o755)

    def run_script(self, name, *args, **overrides):
        return subprocess.run(
            ["bash", "-euo", "pipefail", str(SCRIPTS / name), *args],
            env={**self.env, **overrides},
            text=True,
            capture_output=True,
            timeout=10,
        )

    def request(self, value="1015\n"):
        (self.state / "request").write_text(value)

    def assert_config(self, expected):
        result = self.run_script("launcher.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), f"--config {expected}")

    def test_normal_startup_uses_normal_config(self):
        self.assert_config("/normal.toml")

    def test_fresh_request_is_consumed_and_resets_runfile(self):
        self.request()
        (self.state / "used").touch()
        self.assert_config("/on-demand.toml")
        self.assertFalse((self.state / "request").exists())
        self.assertFalse((self.state / "used").exists())

    def test_request_cannot_authorize_second_start(self):
        self.request()
        self.assert_config("/on-demand.toml")
        self.assert_config("/normal.toml")

    def test_invalid_requests_are_consumed_without_resetting_runfile(self):
        for value in ["999", "1000", "1016", "", "hello", "1+1014", "9" * 100]:
            with self.subTest(value=value):
                self.request(value)
                (self.state / "used").touch()
                self.assert_config("/normal.toml")
                self.assertFalse((self.state / "request").exists())
                self.assertTrue((self.state / "used").exists())

    def test_expired_orphan_cannot_authorize_login(self):
        self.request()
        self.uptime.write_text("1015.01 0.00\n")
        self.assert_config("/normal.toml")

    def test_binary_or_noncanonical_requests_cannot_authorize_login(self):
        for value in [b"10\x0015\n", b"1015\x00\n", b"1015\n\n", b"1015"]:
            with self.subTest(value=value):
                (self.state / "request").write_bytes(value)
                (self.state / "used").touch()
                self.assert_config("/normal.toml")
                self.assertFalse((self.state / "request").exists())
                self.assertTrue((self.state / "used").exists())

    def test_unreadable_uptime_cannot_authorize_login(self):
        self.request()
        self.uptime.unlink()
        result = self.run_script("launcher.sh")
        self.assertNotIn("/on-demand.toml", result.stdout)
        self.assertFalse((self.state / "request").exists())

    def test_helper_publishes_private_short_lived_request(self):
        result = self.run_script("desktop-login.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls.read_text(), "1015\n0o600")
        self.assertEqual(self.state.stat().st_mode & 0o777, 0o700)
        self.assertFalse((self.state / "request.tmp").exists())

    def test_empty_session_list_allows_login(self):
        result = self.run_script("desktop-login.sh", TEST_SESSIONS="")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.calls.exists())

    def test_nonroot_cannot_request_login(self):
        result = self.run_script("desktop-login.sh", TEST_UID="1000")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("sudo", result.stderr)
        self.assertFalse(self.calls.exists())
        self.assertFalse((self.state / "request").exists())

    def test_existing_graphical_session_prevents_restart(self):
        for session_type in ["wayland", "x11"]:
            with self.subTest(session_type=session_type):
                result = self.run_script(
                    "desktop-login.sh", TEST_SESSION_TYPE=session_type
                )
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("graphical session", result.stderr)
                self.assertFalse(self.calls.exists())
                self.assertFalse((self.state / "request").exists())

    def test_session_enumeration_failure_prevents_restart(self):
        result = self.run_script("desktop-login.sh", TEST_LIST_FAIL="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("sessions", result.stderr)
        self.assertFalse(self.calls.exists())
        self.assertFalse((self.state / "request").exists())

    def test_session_inspection_failure_prevents_restart(self):
        result = self.run_script("desktop-login.sh", TEST_SHOW_FAIL="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("session", result.stderr)
        self.assertFalse(self.calls.exists())
        self.assertFalse((self.state / "request").exists())

    def test_empty_session_type_prevents_restart(self):
        result = self.run_script("desktop-login.sh", TEST_SESSION_TYPE="")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("session", result.stderr)
        self.assertFalse(self.calls.exists())

    def test_concurrent_request_is_rejected(self):
        with (self.state / "lock").open("w") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            result = self.run_script("desktop-login.sh")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("request", result.stderr)
        self.assertFalse(self.calls.exists())

    def test_failed_restart_removes_request(self):
        result = self.run_script("desktop-login.sh", TEST_RESTART_FAIL="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("restart", result.stderr)
        self.assertTrue(self.calls.exists())
        self.assertFalse((self.state / "request").exists())

    def test_arbitrary_arguments_are_rejected(self):
        result = self.run_script("desktop-login.sh", "another-user")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Usage", result.stderr)
        self.assertFalse(self.calls.exists())


if __name__ == "__main__":
    unittest.main()
