import os
import sys
import json
import glob
from anthropic import Anthropic

def get_auditor_prompt():
    prompt_path = os.path.join(os.path.dirname(__file__), "..", "agents", "auditor.md")
    if not os.path.exists(prompt_path):
        return "You are an expert Claude Code plugin auditor."
    with open(prompt_path, "r") as f:
        return f.read()

def get_rubric_content():
    rubrics = []
    ref_dir = os.path.join(os.path.dirname(__file__), "..", "skills", "review", "references")
    if not os.path.exists(ref_dir):
        return ""
    
    for md_file in glob.glob(os.path.join(ref_dir, "*.md")):
        with open(md_file, "r") as f:
            rubrics.append(f"--- RUBRIC: {os.path.basename(md_file)} ---\n{f.read()}\n")
    return "\n".join(rubrics)

def gather_artifacts():
    # Only gather markdown files that Claude Code cares about
    patterns = [
        "SKILL.md",
        "skills/**/SKILL.md",
        "agents/**/*.md",
        ".claude/commands/**/*.md",
        ".claude/rules/**/*.md",
        "MEMORY.md",
        "memory/**/*.md",
        ".claude/output-styles/**/*.md",
        "CLAUDE.md",
        "CLAUDE.local.md"
    ]
    
    files = []
    for pattern in patterns:
        files.extend(glob.glob(pattern, recursive=True))
        
    # Filter out rubric files themselves
    files = [f for f in set(files) if "skills/review/references" not in f and "skills/fix/references" not in f]
    
    content = ""
    for f_path in files:
        if os.path.isfile(f_path):
            with open(f_path, "r") as f:
                content += f"\n--- FILE: {f_path} ---\n{f.read()}\n"
    return content

def run_audit():
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print("ANTHROPIC_API_KEY not found. Skipping audit.")
        sys.exit(0)

    artifacts = gather_artifacts()
    if not artifacts.strip():
        print("No Claude Code artifacts found to audit.")
        sys.exit(0)

    client = Anthropic(api_key=api_key)
    
    system_prompt = get_auditor_prompt()
    rubrics = get_rubric_content()
    
    prompt = f"""
I need you to act as the Plugin Auditor. 
Here are the official scoring rubrics you must use:
<rubrics>
{rubrics}
</rubrics>

Here are the artifact files from the repository:
<artifacts>
{artifacts}
</artifacts>

Please perform a "Full plugin directory audit" as defined in your instructions.
Produce ONLY the final output format markdown table (including the 'Badge' line as specified in the review skill output format). Do not include any conversational preamble.
"""

    print("Running Claude Code Auditor via Anthropic API...")
    
    response = client.messages.create(
        model="claude-3-7-sonnet-20250219",
        max_tokens=4000,
        system=system_prompt,
        messages=[
            {"role": "user", "content": prompt}
        ]
    )
    
    report = response.content[0].text
    
    # Save the report so it can be used in PR comments (e.g. via github-script)
    with open("audit_report.md", "w") as f:
        f.write(report)
        
    print(report)
    
    # Optional: fail CI if grade is F
    if "Grade F" in report or "Grade: F" in report:
        print("\nAudit failed with Grade F. Please fix the top issues before merging.")
        sys.exit(1)

if __name__ == "__main__":
    run_audit()
