---
name: git-flow
description: Flujo de ramas feature -> dev -> main con PRs y CI como gate. Usala cada vez que haya que commitear, mergear o hacer release de un cambio — no comitees directo a dev ni a main.
---

# Git flow del programa

Todo cambio viaja: `feature/* -> dev -> main`. Cada salto es un PR. `main`
deploya a producción, así que llega solo lo verificado.

## Pasos

1. Rama desde `dev` con prefijo: `feat/`, `fix/`, `chore/`, `docs/`.
   ```bash
   git checkout dev && git pull && git checkout -b feat/mi-cambio
   ```
2. Trabajá y verificá ANTES de commitear: typecheck, lint y tests del área
   tocada. Rojo = no se commitea.
3. Commit con mensaje que explique el **porqué**, push, y PR a `dev`:
   ```bash
   gh pr create --base dev --title "feat: ..." --body "Por qué: ..."
   ```
4. CI verde -> merge (squash). CI rojo -> se arregla en la rama, nunca se
   mergea "para después".
5. Release: PR de `dev` a `main` listando qué entra. Merge = deploy.
   Verificá la URL de producción antes de dar por cerrado.

## Verificación

- `git log --oneline -3 main` muestra tu merge.
- La URL de prod refleja el cambio (smoke test manual o curl).

## Límites

- Nunca `push --force` a `dev` ni `main`.
- Nunca commit directo a `dev`/`main` — siempre PR, aunque sea de una línea.
- Hotfix urgente: rama desde `main`, PR a `main` con OK explícito, y después
  se porta a `dev` (si no, el próximo release lo pisa).
