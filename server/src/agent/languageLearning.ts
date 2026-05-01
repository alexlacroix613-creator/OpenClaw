export type TokenRecord = {
  surface: string;
  meaning?: string;
  confidence: number;
  examples: string[];
  lastReinforcedAt: string;
};

export function applyLearningEvent(
  token: TokenRecord | undefined,
  event: {
    type: "new_token" | "reinforce_token" | "correct_token" | "reject_token";
    surface: string;
    meaningHypothesis: string;
    confidenceDelta: number;
    evidence: string;
  }
): TokenRecord {
  const now = new Date().toISOString();
  const base: TokenRecord = token ?? {
    surface: event.surface,
    meaning: event.meaningHypothesis,
    confidence: 0,
    examples: [],
    lastReinforcedAt: now
  };

  if (event.type === "reject_token") {
    return {
      ...base,
      confidence: Math.max(0, base.confidence - Math.abs(event.confidenceDelta)),
      examples: [...base.examples, `Rejected: ${event.evidence}`],
      lastReinforcedAt: now
    };
  }

  if (event.type === "correct_token") {
    return {
      ...base,
      meaning: event.meaningHypothesis,
      confidence: clamp01(base.confidence + event.confidenceDelta),
      examples: [...base.examples, `Corrected: ${event.evidence}`],
      lastReinforcedAt: now
    };
  }

  return {
    ...base,
    meaning: base.meaning ?? event.meaningHypothesis,
    confidence: clamp01(base.confidence + event.confidenceDelta),
    examples: [...base.examples, event.evidence].slice(-20),
    lastReinforcedAt: now
  };
}

export function languageStageFromLexicon(tokens: TokenRecord[]) {
  const known = tokens.filter(t => t.confidence >= 0.8).length;
  const partial = tokens.filter(t => t.confidence >= 0.5).length;

  if (known >= 120) return "conversational";
  if (known >= 40) return "phrase";
  if (known >= 12) return "symbolic";
  if (partial >= 4) return "echoic";
  return "prelexical";
}

function clamp01(value: number) {
  return Math.max(0, Math.min(1, value));
}
