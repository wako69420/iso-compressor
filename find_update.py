import json
with open("/Users/chris/.gemini/antigravity/brain/886b1756-f969-4846-91dd-152907d42ef8/.system_generated/logs/transcript_full.jsonl", "r") as f:
    for line in f:
        data = json.loads(line)
        timestamp = data.get("created_at", "")
        if timestamp > "2026-09-22": continue
        if "tool_calls" in data:
            for tc in data["tool_calls"]:
                if tc.get("name") == "run_command":
                    cmd = tc.get("args", {}).get("CommandLine", "")
                    if "releases/latest/download" in cmd or "ISO_Compressor_Windows.exe" in cmd:
                        if "package main" in cmd:
                            print("FOUND GO MAIN!")
                            with open("found_update.go", "w") as out:
                                out.write(cmd)
