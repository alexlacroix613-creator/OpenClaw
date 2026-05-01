import "dotenv/config";
import express from "express";
import cors from "cors";
import { z } from "zod";
import { bootstrapPet, loadPetState } from "./memory/inMemoryStore.js";
import { respondToPetEvent } from "./agent/respondToPetEvent.js";

const app = express();
app.use(cors());
app.use(express.json({ limit: "1mb" }));

const env = z.enum(["dev", "alpha", "production"]).catch("dev").parse(process.env.OPENCLAW_ENV);

const BootstrapSchema = z.object({
  petId: z.string(),
  installToken: z.string(),
  localTimestamp: z.string()
});

const EventSchema = z.object({
  petId: z.string(),
  eventType: z.string(),
  text: z.string().nullable().optional(),
  localTimestamp: z.string()
});

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "openclaw-server" });
});

app.post("/v1/pet/bootstrap", async (req, res) => {
  const parsed = BootstrapSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const installToken = req.header("X-Install-Token") ?? parsed.data.installToken;
  const petState = await bootstrapPet({ installToken, petId: parsed.data.petId });

  res.json({
    mode: "chirp",
    text: petState.stage === "egg" ? "" : "pi...?",
    animation: "egg_awaken",
    emotion: "curious",
    statePatch: {
      moodDelta: 0.01,
      bondDelta: 0,
      energyDelta: -0.001,
      hungerDelta: 0.001
    }
  });
});

app.post("/v1/pet/event", async (req, res) => {
  const parsed = EventSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const installToken = req.header("X-Install-Token");
  if (!installToken) return res.status(401).json({ error: "missing install token" });

  const petState = await loadPetState({ installToken, petId: parsed.data.petId });
  const response = await respondToPetEvent({
    userId: installToken,
    petId: parsed.data.petId,
    task: taskFromEvent(parsed.data.eventType),
    eventType: parsed.data.eventType,
    text: parsed.data.text ?? undefined,
    petState,
    recentMemories: []
  }, env);

  res.json(response);
});

function taskFromEvent(eventType: string) {
  if (eventType === "teaching_text" || eventType === "teaching_audio") return "teaching_response" as const;
  if (eventType === "snap_event") return "snap_caption" as const;
  if (eventType === "screen_observation") return "vision_summary" as const;
  return "baby_reaction" as const;
}

const port = Number(process.env.PORT ?? 8787);
app.listen(port, () => {
  console.log(`OpenClaw server listening on :${port}`);
});
