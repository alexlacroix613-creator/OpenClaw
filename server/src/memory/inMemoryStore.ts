import { PetState } from "../types.js";

const pets = new Map<string, PetState>();

function key(args: { installToken: string; petId: string }) {
  return `${args.installToken}:${args.petId}`;
}

export async function bootstrapPet(args: { installToken: string; petId: string }): Promise<PetState> {
  const k = key(args);
  const existing = pets.get(k);
  if (existing) return existing;

  const newborn: PetState = {
    id: args.petId,
    stage: "egg",
    hunger: 0.2,
    mood: 0.55,
    bond: 0,
    energy: 0.85,
    autonomy: 0,
    knownTokens: [],
    lastInteractionAt: new Date().toISOString()
  };

  pets.set(k, newborn);
  return newborn;
}

export async function loadPetState(args: { installToken: string; petId: string }): Promise<PetState> {
  return bootstrapPet(args);
}

export async function patchPetState(args: {
  installToken: string;
  petId: string;
  patch: Partial<PetState>;
}): Promise<PetState> {
  const current = await loadPetState(args);
  const next = { ...current, ...args.patch, lastInteractionAt: new Date().toISOString() };
  pets.set(key(args), next);
  return next;
}
