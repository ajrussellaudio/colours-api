import { z } from 'zod';

export const colourSchema = z.object({
  id: z.string().uuid().optional(),
  name: z.string().min(1),
  c: z.number().min(0).max(100),
  m: z.number().min(0).max(100),
  y: z.number().min(0).max(100),
  k: z.number().min(0).max(100),
});

export const paletteSchema = z.object({
  name: z.string().min(1),
  colours: z.array(z.string().uuid()),
});
