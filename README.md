# SkillRoom

**Hire graduates on what they can do, not on years of experience.**

SkillRoom is a hiring workflow built on [Switch](https://github.com/sandbox-quantum/switch). Three AI agents and a hiring manager work together in team chat: the agents create a company-specific written assessment, run a live interview with the graduate, and score the results. The hiring manager approves the test and makes the final decision.

Built for the **Flip the Switch Hackathon** (WeMakeDevs × DevTools Academy), Track 1: Best Business Workflow.

<!--
DEMO: before submitting, uncomment this block and fill in the links.

## Demo

- **Video (2-3 min):** <YouTube or Loom link>: a full session through Switch, from job post to APPROVE to the graduate's answers, the interview and the report.
- **Screenshots:** see [`examples/`](examples)
- **Sample report:** [`examples/<graduate-name>-<role>.md`](examples), copied from the Evaluator's `reports/` folder after a real run.
-->

---

## The problem

Most entry-level job adverts ask for experience. Graduates can't get experience without a first job, so many capable people are filtered out by their CV before anyone sees what they can actually do.

## The idea

Instead of asking "how many years have you worked?", SkillRoom asks "can you do this job, at this company, following its rules?"

---

## How it works

Two linked rooms in team chat:

| Room | Who is in it | What happens |
|---|---|---|
| **Hiring room** | Hiring manager, Assessor, Interviewer, Evaluator | Manager sets up the job and approves the test; receives the scored report |
| **Interview room** | Graduate, Assessor, Interviewer | Graduate takes the written assessment and the live interview |

**The workflow**

1. **Set up.** The hiring manager posts the job, a company description, the policies that matter for the role, and the graduate's name in the hiring room.
2. **Assessor drafts the test.** It writes 3 tasks set inside that company (a day-one task, a policy scenario, a reasoning problem) plus a scoring guide.
3. **Human approves.** Nothing reaches the graduate until the manager replies `APPROVE`.
4. **Written assessment.** The Assessor gives the graduate the tasks one at a time in the interview room, each with the company guidelines they need.
5. **Live interview.** The Interviewer asks about the graduate's *own* written answers, then new scenarios, with adaptive follow-ups.
6. **Scored report.** The Evaluator scores Job knowledge, Problem-solving, Communication and Policy compliance, checks each policy, adds timing and integrity notes, suggests a next step, and saves a copy under `reports/`.
7. **Human decides.** The manager reads the report and the full transcript, then decides.

## How Switch is used

Switch is the backbone of SkillRoom; the workflow cannot run without it.

- **Rooms:** a Switch room group with two linked rooms keeps the scoring guide and Evaluator away from the graduate.
- **Agents as teammates:** three Claude Code agents join the rooms with their own names, hand work to each other by @mention, and work alongside two people.
- **Addressing rules:** the Assessor and Interviewer talk to anyone in their rooms; the Evaluator only listens to the hiring manager and the other agents, so a graduate cannot reach it.
- **One template:** everything is created from [`skillroom.template.yaml`](skillroom.template.yaml) in one step in Switch Console.

## Fairness and anti-cheating

We don't watch graduates with spyware. We make cheating pointless:

- **Unique tasks:** every graduate gets different names, amounts and situations.
- **Company-specific:** tasks use the company's own activities and policies, so there is nothing generic to look up.
- **The interview checks the written work:** graduates explain their own answers; people who didn't write them usually can't.
- **Time-limited tasks:** each task has a time limit (8–10 minutes). Message timestamps are recorded, and late answers are flagged as LATE in the report (flagged, not blocked). Timing and integrity notes are for the manager to review; they never lower a skill score.
- **Integrity checks, not accusations:** the Evaluator looks for five warning signs (can't explain own answer, sudden style change, generic AI-like answers that ignore task details, suspicious timing, contradictions between test and interview) and gives a Low / Some / High concern level for a human to review.
- **Fair scoring:** spelling and English as a second language don't lower scores unless the job is mainly writing; the interviewer never asks about personal characteristics.
- **The AI advises, the human decides.**

## Windows setup

Built and tested on Windows 11 with Switch Console v0.40.1, a **Local Switch server** on this computer (switch-core 0.31.0), Claude Code CLI v2.1.318 running as managed agents, and Mattermost in Docker Desktop (served at `http://localhost:60024` in our setup).

**Full step-by-step guide with every command and a troubleshooting table: [WINDOWS-SETUP.md](WINDOWS-SETUP.md).**

The short version:

```powershell
# 1. Claude Code CLI, then reopen PowerShell and sign in
irm https://claude.ai/install.ps1 | iex
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";$env:USERPROFILE\.local\bin", "User")
claude

# 2. WSL 2 for Docker (admin PowerShell), then restart
wsl --update

# 3. If Mattermost says port 60024 is forbidden (admin PowerShell)
net stop winnat
net start winnat
```

On Windows the template form marks every provider "Not supported here", so you create the three agents by hand (**Your Agents → New agent**) and the two rooms in **Your Rooms**. The ready-to-paste settings and instructions are in [`agents/`](agents).

## Run it yourself (Mac / Linux)

**You need:** [Switch Console](https://github.com/sandbox-quantum/switch#getting-started), Docker Desktop, and Claude Code (signed in).

1. Open Switch Console and start a local server (Mattermost comes with it).
2. Go to **Templates**, import `skillroom.template.yaml`, keep the defaults and click **Create**.
3. Open Mattermost. You'll see `skillroom-hiring` and `skillroom-interview`.
4. Paste a demo company from [`demo-companies/`](demo-companies) into **skillroom-hiring**, addressed to `@skillroom-assessor`.
5. Reply `APPROVE`, then answer the tasks and the interview in **skillroom-interview** as the graduate. (Add a second Mattermost account to the interview room to play the graduate separately.)
6. Read the report in the hiring room. A copy is saved in the Evaluator's working directory under `reports/`.

Run one graduate at a time per interview room. To assess several at once, import the template again with a different name prefix (for example `skillroom-ada`), so each graduate gets their own rooms.

### Manual setup (if the template won't import)

If Switch Console won't create agents from the template (on Windows it currently marks every provider "Not supported here"), build the same setup by hand. The ready-to-paste versions are in [`agents/`](agents) (one file per agent, plus [`kickoffs.md`](agents/kickoffs.md)), generated from [`skillroom.template.yaml`](skillroom.template.yaml) with `{team}` replaced by `skillroom`. Windows users: follow [WINDOWS-SETUP.md](WINDOWS-SETUP.md).

1. In **Your Agents → New agent**, create three agents using Claude Code:

   | Agent name | Who can address it | Instructions |
   |---|---|---|
   | `skillroom-assessor` | anyone | the Assessor's `instructions:` block |
   | `skillroom-interviewer` | anyone | the Interviewer's `instructions:` block |
   | `skillroom-evaluator` | owner and agents only | the Evaluator's `instructions:` block |

2. Create two rooms connected to Mattermost and add yourself to both:
   - `skillroom-hiring` with all three agents
   - `skillroom-interview` with the Assessor and the Interviewer only. Never add the Evaluator here.
3. In each room, post the room's `kickoff:` message from the template so the agents introduce themselves.
4. Continue from step 4 of **Run it yourself** above.

## Demo companies (fictional)

- **BrightBooks Accounting:** Junior Accountant
- **Swift Parcels:** Operations Assistant
- **ShopEase Qatar:** Customer Support Agent (the example replayed in "Try the demo" on the website)

Same workflow, completely different tests: SkillRoom adapts to any job.

## What's next

- Voice and video interviews (agents currently read text only)
- Optional, consent-based proctoring (camera, identity check) in a dedicated web app, designed around data-protection rules for biometric data
- Hard time limits enforced by the platform, not just flagged
- More job families, with expert-reviewed tasks for regulated roles (health, legal, finance)
- Comparing several candidates for one role
- Connecting to Slack or Microsoft Teams for companies that already use them

## Built with

Switch · Switch Console · Claude Code · Mattermost · Docker

## License

MIT, see [LICENSE](LICENSE).

## Try it live

**SkillRoom Live** (https://claude.ai/artifact/F5bEgcCasC4rRUvf64RmFv) is a browser version of the same workflow: describe any job, take three AI-written timed tasks as the graduate, answer a four-question interview about your own answers, and get a scored report with timing and integrity signals (pasted text, leaving the tab). It runs on claude.ai using the visitor's own Claude account. The full multi-agent version runs in team chat through Switch, as described above.

## Live site

https://terhemba10.github.io/skillroom/

## Author

Terhemba Alumo
