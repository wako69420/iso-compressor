import json

with open("/Users/chris/.gemini/antigravity/brain/886b1756-f969-4846-91dd-152907d42ef8/.system_generated/logs/transcript_full.jsonl", "r") as f:
    lines = f.readlines()

for line in lines:
    try:
        data = json.loads(line)
        timestamp = data.get("created_at", "")
        if timestamp > "2026-09-22":
            continue
        if "tool_calls" in data:
            for tc in data["tool_calls"]:
                if tc.get("name") == "run_command":
                    cmd = tc.get("args", {}).get("CommandLine", "")
                    if "func main()" in cmd and "package main" in cmd:
                        with open("recovered_main.go", "w") as out:
                            # It's a bash command `cat << 'EOF' > ...` so let's just write the whole command
                            out.write(cmd)
    except:
        pass
