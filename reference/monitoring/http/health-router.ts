import { Router } from "express";

// reference/monitoring — reusable Express health-check router (OPS-040.1,
// ADR-040). Generalizes reference/application's inline /healthz route into
// a parameterized, copyable module: not tied to any one service's domain
// logic.

export type DependencyCheck = () => Promise<boolean>;

export interface HealthRouterOptions {
  serviceName: string;
  // Optional dependency probes (e.g. "SELECT 1" against the database),
  // checked only by /readyz, never /healthz. Liveness MUST NOT depend on a
  // downstream system: if the process itself is up, it is alive, even if
  // its database is briefly unreachable. Conflating the two turns a
  // database blip into a restart loop that cannot fix a database outage --
  // a well-known anti-pattern this router avoids by construction.
  readinessChecks?: Record<string, DependencyCheck>;
}

export function healthRouter(options: HealthRouterOptions): Router {
  const router = Router();

  // The one thing OPS-040.1 actually requires: liveness. reference/
  // deployment's health gate, and any external uptime check
  // (reference/monitoring's own terraform/monitoring.tf), poll this.
  router.get("/healthz", (_req, res) => {
    res.status(200).json({ status: "ok", service: options.serviceName });
  });

  // Optional: readiness, gated on whatever dependency checks the
  // consuming service actually wants. Absent any checks, this behaves
  // identically to /healthz.
  const checks = options.readinessChecks ?? {};
  router.get("/readyz", async (_req, res) => {
    const results = await Promise.all(
      Object.entries(checks).map(async ([name, check]) => {
        try {
          return [name, await check()] as const;
        } catch {
          return [name, false] as const;
        }
      }),
    );
    const allHealthy = results.every(([, ok]) => ok);
    res.status(allHealthy ? 200 : 503).json({
      status: allHealthy ? "ok" : "unavailable",
      service: options.serviceName,
      checks: Object.fromEntries(results),
    });
  });

  return router;
}
