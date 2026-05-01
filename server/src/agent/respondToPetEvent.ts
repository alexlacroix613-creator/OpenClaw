import { z } from "zod";
import { callOpenRouterJSON } from "../llm/openRouterClient.js";
import { chooseModel, PetTask } from "../llm/modelRouter.js";
import { buildTabulaRasaPrompt } from "./tabulaRasaPrompt.js";
import { localFallbackReaction } from "./localFallbackReaction.js";
import { patchPetState } from "../memory/inMemoryStore.js";
import { PetStage } from "../types.js";

const AgentOutputSchema = z.object({
  mode: z.enum(["chirp", "gesture", "word_fragment", "phrase", "conversation"]),
  text: z.string(),
  animation: z.string(),
  emotion: z.string(),
  statePatch: z.object({
    moodDelta: z.number(),
    bondDelta: z.number(),
    energyDelta: z.number(),
    hungerDelta: z.number()
  }),
  learningEvents: z.array(z.any()).optional(),
  memoryCandidates: z.array(z.any()).optional(),
  initiativeCandidate: z.any().optional()
});

export type PetEvent = {
  userId: string;
  petId: string;
  task: PetTask;
  eventType: string;
  text?: string;
  petState: unknown;
  recentMemories: unknown[];
};

export async function respondToPetEvent(event: PetEvent, environment: "dev" | "alpha" | "production") {
  const choice = chooseModel(event.task, environment);

  try {
    const raw = await callOpenRouterJSON<unknown>({
      model: choice.model,
      system: buildTabulaRasaPrompt(),
      user: {
        pet_state: event.petState,
        recent_memories: event.recentMemories,
        current_event: {
          type: event.eventType,
          text: event.text
        }
      },
      timeoutMs: choice.maxLatencyMs,
      temperature: 0.42
    });

    const parsed = AgentOutputSchema.parse(raw);
    await persistPatch(event, parsed.statePatch);
    return parsed;
  } catch (error) {
    if (!choice.fallbackLocal) throw error;
    const fallback = localFallbackReaction(event);
    await persistPatch(event, fallback.statePatch);
    return fallback;
  }
}

async function persistPatch(event: PetEvent, patch: {
  moodDelta: number;
  bondDelta: number;
  energyDelta: number;
  hungerDelta: number;
}) {
  const pet = event.petState as any;
  await patchPetState({
    installToken: event.userId,
    petId: event.petId,
    patch: {
      mood: clamp01((pet.mood ?? 0.55) + patch.moodDelta),
      bond: clamp01((pet.bond ?? 0) + patch.bondDelta),
      energy: clamp01((pet.energy ?? 0.85) + patch.energyDelta),
      hunger: clamp01((pet.hunger ?? 0.2) + patch.hungerDelta),
      stage: nextStage(pet.stage, event.eventType)
    }
  });
}

function nextStage(stage: string | undefined, eventType: string): PetStage {
  if (stage === "egg" && eventType === "tap_pet") return "hatchling";
  if (stage === "hatchling" && eventType.startsWith("teaching")) return "learner";
  if (stage === "egg" || stage === "hatchling" || stage === "learner" || stage === "toddler" || stage === "buddy" || stage === "bff") return stage;
  return "egg";
}

function clamp01(value: number) {
  return Math.max(0, Math.min(1, value));
}
