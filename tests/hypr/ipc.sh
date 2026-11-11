#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
python3 - <<'PY'
import json, os, pathlib, subprocess, tempfile
root = pathlib.Path.cwd()
with tempfile.TemporaryDirectory(prefix='hypr-ipc-', dir='/tmp/opencode') as directory:
    tmp = pathlib.Path(directory)
    log = tmp/'calls.jsonl'
    fake = tmp/'hyprctl'
    fake.write_text('''#!/usr/bin/env python3
import json, os, sys
with open(os.environ['IPC_LOG'], 'a') as f: f.write(json.dumps(sys.argv[1:])+'\\n')
if sys.argv[1:] == ['clients', '-j']: print(os.environ['CLIENTS'])
if sys.argv[1:] == ['-j', 'locked']: print(os.environ['LOCKED_STATE'])
''')
    fake.chmod(0o755)
    (tmp/'pidof').write_text('#!/usr/bin/env bash\nexit "${PIDOF_STATUS:-0}"\n')
    (tmp/'pidof').chmod(0o755)
    env = {**os.environ, 'PATH':str(tmp)+':'+os.environ['PATH'], 'IPC_LOG':str(log),
           'XDG_RUNTIME_DIR':str(tmp), 'HYPRLAND_INSTANCE_SIGNATURE':'fake', 'CLIENTS':'[]'}
    def run(script, *args, clients=None, shell=False, locked_state='{"locked":true}', expected_status=0):
        log.write_text('')
        e = {**env, 'CLIENTS':json.dumps(clients or []), 'LOCKED_STATE':locked_state}
        r = subprocess.run(['bash', '-c', script] if shell else ['bash', str(root/script), *args], env=e, capture_output=True, text=True)
        assert (r.returncode != 0 if expected_status is None else r.returncode == expected_status), (script, r.returncode, r.stderr)
        calls = [json.loads(line) for line in log.read_text().splitlines()]
        for call in calls:
            if call[0] == 'dispatch': assert len(call)==2 and call[1].startswith('hl.dsp.'), call
        return [call[1] for call in calls if call[0]=='dispatch']

    clients = [{'class':'editor','address':'0x11'}, {'class':'editor','address':'0x22'}, {'class':'other','address':'0x33'}]
    calls = run('bin/dots-focus-layout.sh', '--place','editor','5', '--reset-fullscreen','editor', '--focus-workspace','7', clients=clients)
    assert calls == [
        'hl.dsp.focus({window="address:0x11"})', 'hl.dsp.window.fullscreen({mode="fullscreen",action="set"})',
        'hl.dsp.focus({window="address:0x22"})', 'hl.dsp.window.fullscreen({mode="fullscreen",action="set"})',
        'hl.dsp.window.move({workspace="5",window="address:0x11",follow=false})',
        'hl.dsp.window.move({workspace="5",window="address:0x22",follow=false})',
        'hl.dsp.focus({window="address:0x11"})', 'hl.dsp.window.fullscreen({mode="fullscreen",action="unset"})', 'hl.dsp.window.fullscreen({mode="fullscreen",action="set"})',
        'hl.dsp.focus({window="address:0x22"})', 'hl.dsp.window.fullscreen({mode="fullscreen",action="unset"})', 'hl.dsp.window.fullscreen({mode="fullscreen",action="set"})',
        'hl.dsp.focus({workspace="7"})'], calls
    assert run('bin/dots-focus-layout.sh', '--place','absent','5') == []
    assert run('bin/dots-focus-layout.sh', '--place','absent','5','--focus-workspace','7') == ['hl.dsp.focus({workspace="7"})']
    # Untrusted selector text must remain data, never executable Lua.
    dangerous = 'name:x"}); os.execute("touch /tmp/unsafe"); --'
    calls = run('bin/dots-focus-layout.sh', '--place','editor',dangerous, '--focus-workspace',dangerous, clients=clients[:1])
    quoted = json.dumps(dangerous)
    assert calls == [f'hl.dsp.window.move({{workspace={quoted},window="address:0x11",follow=false}})', f'hl.dsp.focus({{workspace={quoted}}})']

    # Execute the actual embedded DPMS commands, without invoking a real compositor.
    dpms = [line.split('=',1)[1].strip() for line in (root/'hypr/hypridle.conf').read_text().splitlines() if 'hyprctl' in line]
    assert len(dpms)==5
    for command, action in zip(dpms, ['on','off','on','off','on']):
        assert run(command, shell=True) == [f'hl.dsp.dpms({{action="{action}"}})']
    # The two short-timeout actions must use real lock state, not hyprlock's PID.
    for command in dpms[1:3]:
        for state in ('{"locked":false}', '{}', 'null', 'not-json', ''):
            assert run(command, shell=True, locked_state=state, expected_status=None) == [], (command, state)

print('IPC tests passed: client placement/fullscreen, absent clients, quoting, DPMS')
PY
