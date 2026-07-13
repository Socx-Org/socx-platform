---
id: ADR-160
title: Infrastructure-as-code tooling
status: Approved
category: Operations
version: "1.0"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - INF-010
    - TEC-010
  standards:
    - OPS-020
    - OPS-010
  current_state:
    - CS-TEC-010
    - CS-INF-010
  reference:
    - reference/deployment
  runbooks: []
  adrs:
    - ADR-040
    - ADR-150
supersedes: []
superseded_by: null
---

# ADR-160 — Infrastructure-as-code tooling

## Context

`OPS-020` mandates that infrastructure is defined and changed as code, but names no tool — and without one approved tool, infrastructure-as-code drifts per project. `CS-TEC-010` and `CS-INF-010` show a real divergence today: `ghs` contains an `infra/terraform` directory (not confirmed applied to any live infrastructure), while `platform-infra` manages the actual droplet through shell scripts plus systemd/nginx files (currently empty scaffolding). So there is a genuine fork: Terraform versus the shell-script status quo.

## Decision

The platform adopts **Terraform** as its infrastructure-as-code tool for provisioning droplet-level, DNS, and edge infrastructure — using the existing `ghs/infra/terraform` as a starting point — with `platform-infra`'s shell scripts reduced to deploy-time glue rather than infrastructure definition. Scope is the current single-droplet model (`ADR-040`) and is revisited if that changes. Terraform state storage is a follow-up implementation detail, not settled here.

## Alternatives Considered

- **Terraform — selected.** Declarative, with provider support for DigitalOcean and DNS, and already partially present in `ghs`. Main new operational concern: managing Terraform state.
- **Ansible** — strong for host configuration, weaker as a provisioning source of truth; could complement Terraform later rather than replace it.
- **DigitalOcean-native (`doctl` / App Platform specs)** — lowest friction for a single droplet, but vendor-locked and thin for DNS and edge configuration.
- **Status-quo shell scripts (`platform-infra`)** — Rejected as the IaC source of truth: imperative and hard to review for drift; retained only as deploy-time glue.

## Consequences

- Gives `OPS-020` a concrete tool and gives `reference/deployment` something specific to demonstrate.
- Requires deciding Terraform state storage (a follow-up implementation detail).
- The `ghs` / `platform-infra` divergence resolves toward one tool; migrating `platform-infra`'s shell approach is follow-on work.
- Coupled to the hosting model in `ADR-040`; the CI pipeline (`ADR-150`) is the natural place to run `plan`/`apply`.

## Related Documents

- Architecture: `INF-010`, `TEC-010`
- Standards: `OPS-020`, `OPS-010`
- Current-State documentation: `CS-TEC-010`, `CS-INF-010`
- Reference Implementations: `reference/deployment`
- Runbooks: none yet
- ADRs: `ADR-040` (the infrastructure this provisions), `ADR-150` (where `plan`/`apply` runs)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-14 | Initial draft | Socx   |
| 1.0     | 2026-07-14 | Approved      | Socx   |
