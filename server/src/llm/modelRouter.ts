export type PetTask =
  | "baby_reaction"
  | "teaching_response"
  | "memory_summary"
  | "conversation"
  | "initiative_tick"
  | "snap_caption"
  | "vision_summary";

export type ModelChoice = {
  model: string;
  maxLatencyMs: number;
  fallbackLocal: boolean;
};

export function chooseModel(task: PetTask, environment: "dev" | "alpha" | "production"): ModelChoice {
  if (environment === "dev") {
    return {
      model: process.env.OPENROUTER_FREE_MODEL ?? "openrouter/free",
      maxLatencyMs: 10_000,
      fallbackLocal: true
    };
  }

  if (environment === "alpha") {
    switch (task) {
      case "baby_reaction":
      case "teaching_response":
      case "memory_summary":
      case "snap_caption":
        return {
          model: process.env.OPENROUTER_FREE_MODEL ?? "openrouter/free",
          maxLatencyMs: 8_000,
          fallbackLocal: true
        };
      default:
        return {
          model: process.env.OPENROUTER_MAIN_MODEL ?? "openrouter/free",
          maxLatencyMs: 12_000,
          fallbackLocal: true
        };
    }
  }

  switch (task) {
    case "baby_reaction":
      return { model: required("OPENROUTER_SMALL_MODEL"), maxLatencyMs: 3_000, fallbackLocal: true };
    case "teaching_response":
    case "memory_summary":
    case "snap_caption":
      return { model: required("OPENROUTER_CHEAP_MODEL"), maxLatencyMs: 5_000, fallbackLocal: true };
    case "conversation":
    case "initiative_tick":
      return { model: required("OPENROUTER_MAIN_MODEL"), maxLatencyMs: 8_000, fallbackLocal: true };
    case "vision_summary":
      return { model: required("OPENROUTER_VISION_MODEL"), maxLatencyMs: 10_000, fallbackLocal: true };
  }
}

function required(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`Missing required env var ${name}`);
  return value;
}
