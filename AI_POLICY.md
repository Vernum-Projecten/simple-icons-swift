# AI policy

You may use AI tools (coding assistants, agents, chat) for any part of a
contribution. What applies to every contribution applies to yours:

- **You are responsible for every line.** You submit it, so you answer for
  it in review, as if you wrote it by hand.
- **You understand it.** You can explain what each change does and why, and
  you can change it when a reviewer asks.
- **You tested it.** It passes the gates in [CONTRIBUTING.md](CONTRIBUTING.md).
- **You can license it.** Submit only what you have the right to contribute
  under the [MIT License](LICENSE). Do not submit generated code that copies
  someone else's work under terms that do not allow this.
- **It follows the project's rules**, as [CLAUDE.md](CLAUDE.md) and
  [.claude/rules/swift.md](.claude/rules/swift.md) set them out. Both are
  written to be read by people and by coding agents alike, and the
  repository's `.claude/` folder configures Claude Code with the same rules
  and hooks.

You do not have to say whether or how you used AI. Commits and pull
requests carry no AI attribution: no `Co-authored-by` line for a tool, no
"Generated with" line, no robot emoji. A commit describes the change, and
its author is the person who submits it. The `commit-msg` hook in
`.githooks/` removes such lines.

Pull requests, issues and comments are read by a person. Keep them short
and specific, and check generated prose for the tells the project avoids
(em dashes, a middle dot as a separator, buzzwords).

The package itself contains no AI model and sends nothing anywhere: it is
icon data and drawing code, with no network access.
