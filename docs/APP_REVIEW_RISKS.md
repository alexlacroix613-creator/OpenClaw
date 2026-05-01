# App Review Risk Checklist

| Area | Risk | Required mitigation |
|---|---|---|
| PiP companion | Apple may view PiP as misused if it is not media-like | Present as animated companion stream, not global UI overlay |
| Screen watch mode | Privacy concern | Explicit ReplayKit start, clear stop control, visible state, redaction |
| Dynamic Island | Misuse as permanent HUD | Use for active states only, update when state changes |
| AI pet agency | Dependency/manipulation concern | Rate limits, quiet hours, no coercive copy |
| Memory | PII retention | Memory viewer, delete/export, retention policy |
| Snapchat | Silent sending impossible | User-approved Creative Kit handoff only |
| Children | Safety/regulatory | Age gate, parental controls if targeting minors |

## Copy Rules

Avoid:

- “It is conscious.”
- “It watches everything automatically.”
- “It sends Snaps for you.”
- “Never leave it alone.”

Use:

- “It learns from what you teach it.”
- “Open its eyes for this session.”
- “It made something you can send.”
- “You control its memories.”
