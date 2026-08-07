import type { Pool } from "pg";

export interface Widget {
  id: number;
  name: string;
  createdAt: string;
}

// Narrow interface exposed upward -- the application layer depends on this
// shape, never on `pg` or SQL directly (ADR-060).
export interface WidgetsRepository {
  list(): Promise<Widget[]>;
  create(name: string): Promise<Widget>;
}

function toWidget(row: { id: number; name: string; created_at: Date }): Widget {
  return { id: row.id, name: row.name, createdAt: row.created_at.toISOString() };
}

export function createWidgetsRepository(pool: Pool): WidgetsRepository {
  return {
    async list() {
      const result = await pool.query<{ id: number; name: string; created_at: Date }>(
        "SELECT id, name, created_at FROM widgets ORDER BY id",
      );
      return result.rows.map(toWidget);
    },

    async create(name: string) {
      const result = await pool.query<{ id: number; name: string; created_at: Date }>(
        "INSERT INTO widgets (name) VALUES ($1) RETURNING id, name, created_at",
        [name],
      );
      return toWidget(result.rows[0]!);
    },
  };
}
