# SkillRoom

**Hire graduates on what they can do, not on years of experience.**

SkillRoom is a hiring workflow built on [Switch](https://github.com/sandbox-quantum/switch). Three AI agents and a hiring manager work together in team chat: the agents create a company-specific written assessment, run a live interview with the graduate, and score the results. The hiring manager approves the test and makes the final decision.

Built for the **Flip the Switch Hackathon** (WeMakeDevs × DevTools Academy), Track 1: Best Business Workflow.

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
6. **Scored report.** The Evaluator scores Job knowledge, Problem-solving, Communication and Policy compliance, checks each policy, adds integrity notes, and suggests a next step.
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
- **Time-limited tasks:** each task has a time limit (8–10 minutes). Message timestamps are recorded, and late answers are flagged as LATE in the report (flagged, not blocked).
- **Integrity checks, not accusations:** the Evaluator looks for five warning signs (can't explain own answer, sudden style change, generic AI-like answers that ignore task details, suspicious timing, contradictions between test and interview) and gives a Low / Some / High concern level for a human to review.
- **Fair scoring:** spelling and English as a second language don't lower scores unless the job is mainly writing; the interviewer never asks about personal characteristics.
- **The AI advises, the human decides.**

## Windows setup notes

Built and tested on Windows with Switch Console (early access). What we learned:

- Install the **Claude Code CLI** (`irm https://claude.ai/install.ps1 | iex`), add `%USERPROFILE%\.local\bin` to PATH, and run `claude` once to sign in. Switch needs the CLI, not the desktop app.
- On Windows, agents run as **managed agents**. The template form currently marks every provider "Not supported here", so we created the three agents with **Your Agents → New agent** using the same instructions as the template.
- Mattermost needs Docker, and Docker needs a working **WSL 2**. If Docker won't start, run `wsl --update`, then restart.
- Give each reply 1–3 minutes: the server, Mattermost and several Claude Code sessions share one PC.

## Run it yourself

**You need:** [Switch Console](https://github.com/sandbox-quantum/switch#getting-started), Docker Desktop, and Claude Code (signed in).

1. Open Switch Console and start a local server (Mattermost comes with it).
2. Go to **Templates**, import `skillroom.template.yaml`, keep the defaults and click **Create**.
3. Open Mattermost. You'll see `skillroom-hiring` and `skillroom-interview`.
4. Paste a demo company from [`demo-companies/`](demo-companies) into **skillroom-hiring**, addressed to `@skillroom-assessor`.
5. Reply `APPROVE`, then answer the tasks and the interview in **skillroom-interview** as the graduate. (Add a second Mattermost account to the interview room to play the graduate separately.)
6. Read the report in the hiring room. A copy is saved in the Evaluator's working directory under `reports/`.

## Demo companies (fictional)

- **BrightBooks Accounting:** Junior Accountant
- **Swift Parcels:** Operations Assistant

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

## Author

Terhemba Alumo
