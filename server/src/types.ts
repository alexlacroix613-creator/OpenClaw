export type PetStage = "egg" | "hatchling" | "learner" | "toddler" | "buddy" | "bff";

export type LearnedToken = {
  id: string;
  surface: string;
  phoneticHint?: string;
  meaning?: string;
  confidence: number;
  examples: string[];
  firstLearnedAt: string;
  lastReinforcedAt: string;
};

export type PetState = {
  id: string;
  name?: string;
  stage: PetStage;
  hunger: number;
  mood: number;
  bond: number;
  energy: number;
  autonomy: number;
  knownTokens: LearnedToken[];
  memoryDigest?: string;
  lastInteractionAt: string;
};

export type PetVisibleResponse = {
  mode: "chirp" | "gesture" | "word_fragment" | "phrase" | "conversation";
  text: string;
  animation: string;
  emotion: string;
  statePatch: {
    moodDelta: number;
    bondDelta: number;
    energyDelta: number;
    hungerDelta: number;
  };
};
