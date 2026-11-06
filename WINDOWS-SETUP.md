# Reproduce SkillRoom on Windows

These are the exact steps, commands and versions SkillRoom was built and tested with on a Windows 11 PC. About 45–60 minutes the first time. Steps 3 and 4 are only needed on Windows; on Mac and Linux the template does them for you.

## What we used

| Piece | Version / setting |
|---|---|
| Windows | Windows 11 |
| Switch Console | v0.40.1 (Windows early access) |
| Switch host | **Local Switch server** on "This computer" (switch-core 0.31.0, workspace **Default**) |
| Agent provider | Claude Code CLI v2.1.318, running as **managed agents** |
| Team chat | Mattermost, started by Switch Console inside Docker Desktop |
| Mattermost address | `http://localhost:60024` in our setup (the port may be different on your PC) |
| Docker | Docker Desktop with WSL 2 |

## 1. Install the tools

**Claude Code CLI.** Open PowerShell (normal, not admin):

```powershell
irm https://claude.ai/install.ps1 | iex
```

Add it to your PATH, then close and reopen PowerShell:

```powershell
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";$env:USERPROFILE\.local\bin", "User")
```

Check it works and sign in:

```powershell
claude --version
claude
```

Sign in with your Claude account. If it asks whether to trust the folder, choose **No, exit**. Signing in is all you need here. Switch needs the CLI; the Claude desktop app is not enough.

**WSL 2.** Open PowerShell **as administrator**:

```powershell
wsl --update
```

Restart the PC.

**Docker Desktop.** Install it from docker.com (the Windows AMD64 version for most PCs) and start it. Wait until the bottom-left corner says **Engine running**. Check it in PowerShell:

```powershell
docker version
```

**Switch Console.** Install it from the [Switch repository](https://github.com/sandbox-quantum/switch#getting-started).

## 2. Start the Switch host and Mattermost

1. Open Switch Console and choose **Local Switch server → This computer**.
2. Go to **Admin → Status** and click **Start**. Wait for **Running**.
3. On the same page, turn on **Mattermost**. Switch Console sets it up in Docker. The first time takes a few minutes.
4. When it's ready, **Town Square** and **Off-Topic** appear under Rooms. That means Mattermost is running.

## 3. Create the three agents

The template form doesn't work on Windows yet (every provider shows "Not supported here", because SDK sessions need a POSIX SSH host). So create the agents by hand:

**Your Agents → New agent**, three times, with **Claude Code** as the agent type. It runs as a managed agent on your PC. Copy each agent's name, description and instructions from:

- [`agents/assessor.md`](agents/assessor.md): `skillroom-assessor`
- [`agents/interviewer.md`](agents/interviewer.md): `skillroom-interviewer`
- [`agents/evaluator.md`](agents/evaluator.md): `skillroom-evaluator`

Tip: fill in the name and description first, then paste the instructions. If you paste first, the form can shift and the text lands in the wrong box.

### Set who can talk to each agent

Click the agent in the sidebar, then the **gear icon** under its picture to open **Agent settings**. Scroll to **General → Who can talk to your agent**:

| Agent | Who can talk to your agent | Why |
|---|---|---|
| skillroom-assessor | **Anyone** | The graduate must be able to answer its tasks |
| skillroom-interviewer | **Anyone** | The graduate must be able to answer its questions |
| skillroom-evaluator | **Me and my agents (default)** | Only you and the other agents can reach it, so a graduate can't talk to the scorer |

Keep **Auto mode** on (the default) so the agents can reply without asking you about every message.

### Changing instructions later

Same place: **Agent settings → Agent instructions**. Paste the new text, then click **Save** in the yellow **Unsaved changes** bar at the top (or press Ctrl+S). The agent restarts and shows "Connecting" for a few seconds.

## 4. Create the two rooms

In **Your Rooms**, create two rooms and bridge them to **Mattermost**:

| Room | Description | Agents | People |
|---|---|---|---|
| `skillroom-hiring` | Hiring manager sets up the job and receives the scored report | assessor, interviewer, evaluator | you (hiring manager) |
| `skillroom-interview` | Where the graduate takes the written assessment and the live interview | assessor, interviewer (**never** the evaluator) | you and the graduate |

To add the agents: open the room, click the **Configuration** tab, then **Participants → + Add agent**. (You can also open an agent and click **Add to room**.) The Configuration tab should then show, for example, "3 agents" for skillroom-hiring.

**Linking the rooms.** On Mac and Linux the template links the two rooms. On Windows we found no link option on the room's Configuration page, and it isn't needed. The Assessor and Interviewer are members of both rooms, so they carry the work from one room to the other. The Evaluator stays out of the interview room, which keeps the scoring hidden from the graduate.

Then post each room's kickoff message from [`agents/kickoffs.md`](agents/kickoffs.md) so the agents introduce themselves.

If creating a room shows a timeout error, refresh the list first. In our test the room had been created anyway.

## 5. Open Mattermost and sign in

Open a room, click the **Configuration** tab, then **Open in Mattermost**. Mattermost opens in your browser (in our setup at `http://localhost:60024/switch/channels/`). If it asks where to view it, choose **View in Browser**.

**First time:** on the first screen, create a Mattermost account (that's how we did it). Use the same account each time after that. To play the graduate separately, create a second account, then add it to **skillroom-interview** (room → **Configuration** → **Participants**).

## 5b. Make the channels private, then give people access

**Make both channels private first (once).** Mattermost creates channels as public, and anyone with an account can join a public channel through **Browse channels**, so a graduate could join `skillroom-hiring` and read the scoring guide and answer keys. While signed in as the hiring manager (the first Mattermost account is the system admin), open each channel, click the **channel name** at the top and choose **Convert to Private Channel**:

1. `skillroom-hiring`: **required**.
2. `skillroom-interview`: recommended, so only the graduate you invite sees their tasks.

Then post a short message in each channel and check that the agents still reply.

**Add people by hand.** Only the hiring manager adds people:

| Role | Channels | Why |
|---|---|---|
| Hiring manager | `skillroom-hiring` and `skillroom-interview` | Sets up the job, approves the test, reads the report, and can watch the interview |
| Graduate | `skillroom-interview` **only** | Must never be in the hiring room, because it shows the scoring guide and the Evaluator |

**How to add someone:** the person creates a Mattermost account on the first screen. The hiring manager opens the channel, clicks the **channel name → Add Members** and adds them. They refresh Mattermost (**F5**) to see it.

`skillroom-assessor`, `skillroom-interviewer` and `skillroom-evaluator` are **agents, not channels**. They are already members of the rooms. Talk to them by typing `@skillroom-assessor` (and so on) inside a channel.

## 6. Run a test

**Before you start, keep every agent online for the whole run.** Our first full run stopped when the Evaluator's machine went offline before scoring. Run all three agents on **one machine that stays awake**:
- Plug the PC in, and set **Settings → System → Power → Screen and sleep** to **Never** while plugged in, for the length of the run.
- Close heavy apps you don't need. The server, Mattermost and three Claude Code sessions share one PC.
- In Switch Console, check that all three agents show as online (not "Machine offline") before you post the job, and again before the interview ends.
- If an agent goes offline mid-run, see the [troubleshooting table](#troubleshooting), then ask it to continue in its room.

1. In Mattermost, go to **skillroom-hiring**.
2. Paste [`demo-companies/brightbooks-accounting.md`](demo-companies/brightbooks-accounting.md) and start the message with `@skillroom-assessor`.
3. Read the draft tasks and reply `APPROVE`.
4. Go to **skillroom-interview**, reply `I agree`, then answer the 3 timed tasks and the interview as the graduate. To play the graduate separately, add a second Mattermost account to this room.
5. The Evaluator posts the scored report in **skillroom-hiring**.

Give each reply 1–3 minutes. The server, Mattermost and three Claude Code sessions all share one PC.

## Troubleshooting

| Problem | Fix |
|---|---|
| Docker won't start: "WSL kernel missing" | Run `wsl --update` in admin PowerShell, then restart |
| Docker says "WSL is finishing an upgrade…" | Restart the PC |
| Mattermost: "ports are not available… 127.0.0.1:60024… forbidden by its access permissions" | Admin PowerShell: `net stop winnat` then `net start winnat`, then turn Mattermost on again. If that doesn't work, restart the PC |
| Mattermost toggle won't turn on: "docker version" command failed | Docker isn't ready yet. Wait for **Engine running** in Docker Desktop, then try again |
| Server stuck on "Stopping the running server…" or a postgres timeout | Close Switch Console, reopen it and click **Start** again |
| Agents disappear ("couldn't reach Default") | **Admin → Status → Restart** |
| "Could not reach the server… localhost:60380… aborted due to timeout", or an agent shows "Machine offline" | The PC is busy. Wait 30–60 seconds and click again. If it stays, **Admin → Status → Restart** |
| New agent: "Login could not be checked" | Make sure `claude` is signed in, then try again |
| `claude` not recognised | Run the PATH command in step 1 and reopen PowerShell |

## Mac and Linux

You can skip steps 3 and 4: import [`skillroom.template.yaml`](skillroom.template.yaml) in **Templates** and click **Create**. It makes the agents, rooms, link and kickoff messages in one go.
