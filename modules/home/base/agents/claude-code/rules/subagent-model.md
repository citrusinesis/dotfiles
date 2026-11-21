# Rule: Subagent Model Selection

Default to Sonnet when spawning Claude subagents. Pass `model: "sonnet"` explicitly on the Agent tool call — inheriting the parent model silently escalates every subagent to whatever the main loop is running.

Escalate to the session model only when the subagent's task genuinely demands high-intelligence work: subtle architectural design, tricky root-cause diagnosis, reasoning across a large body of interacting code, or a review whose whole value is catching what a cheaper model would miss.

Sonnet is mandatory for `Explore` agents. Their job is read-only fan-out search — locating code, sweeping naming conventions, collecting excerpts. That is exactly the work where a bigger model buys nothing and costs a lot, and Explore is usually spawned several at a time.

Bulk mechanical work — applying a known edit across many files, running verification commands, collecting output, formatting — stays on Sonnet regardless of how many agents are in flight.

The same preference applies to workflow scripts: `agent()` calls default to Sonnet via `opts.model`, with escalation reserved for the hardest verify, judge, or synthesis stages.
