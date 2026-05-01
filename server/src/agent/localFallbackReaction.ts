export function localFallbackReaction(event: {
  eventType: string;
  text?: string;
  petState: any;
}) {
  const stage = event.petState?.stage ?? "hatchling";

  if (event.eventType === "tap_pet") {
    return {
      mode: "chirp" as const,
      text: stage === "egg" ? "" : "pi...?",
      animation: stage === "egg" ? "egg_awaken" : "look_at_user",
      emotion: "curious",
      statePatch: {
        moodDelta: 0.015,
        bondDelta: 0.01,
        energyDelta: -0.002,
        hungerDelta: 0.001
      },
      learningEvents: [],
      memoryCandidates: []
    };
  }

  if (event.eventType === "teaching_text" || event.eventType === "teaching_audio") {
    const fragment = event.text ? `${event.text.slice(0, 3)}...` : "mmm...";
    return {
      mode: "word_fragment" as const,
      text: fragment,
      animation: "mouth_trying_sound",
      emotion: "focused",
      statePatch: {
        moodDelta: 0.02,
        bondDelta: 0.018,
        energyDelta: -0.01,
        hungerDelta: 0.003
      },
      learningEvents: event.text ? [{
        type: "new_token",
        surface: event.text,
        meaningHypothesis: "unknown user-taught sound",
        confidenceDelta: 0.08,
        evidence: "Fallback teaching event"
      }] : [],
      memoryCandidates: []
    };
  }

  if (event.eventType === "claw_capsule") {
    return {
      mode: "gesture" as const,
      text: event.text === "word" ? "?" : "",
      animation: `capsule_${event.text ?? "unknown"}_react`,
      emotion: "curious",
      statePatch: {
        moodDelta: 0.01,
        bondDelta: 0.005,
        energyDelta: -0.004,
        hungerDelta: 0.002
      },
      learningEvents: [],
      memoryCandidates: []
    };
  }

  return {
    mode: "gesture" as const,
    text: "",
    animation: "float_idle_look_up",
    emotion: "calm",
    statePatch: {
      moodDelta: 0,
      bondDelta: 0,
      energyDelta: -0.002,
      hungerDelta: 0.001
    },
    learningEvents: [],
    memoryCandidates: []
  };
}
