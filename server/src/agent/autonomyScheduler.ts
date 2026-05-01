export type InitiativeCandidate = {
  shouldInitiateLater: boolean;
  reason: string;
  channel: "push" | "pip" | "dynamic_island" | "snap_suggestion" | "none";
  cooldownMinutes: number;
};

export function shouldScheduleInitiative(candidate: InitiativeCandidate, userSettings: {
  allowPush: boolean;
  allowSnapSuggestions: boolean;
  quietHoursActive: boolean;
}) {
  if (!candidate.shouldInitiateLater) return false;
  if (candidate.channel === "none") return false;
  if (userSettings.quietHoursActive) return false;
  if (candidate.channel === "push" && !userSettings.allowPush) return false;
  if (candidate.channel === "snap_suggestion" && !userSettings.allowSnapSuggestions) return false;
  return true;
}
