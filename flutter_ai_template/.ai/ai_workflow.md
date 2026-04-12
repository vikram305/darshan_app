# Ultimate AI Feature Creation Workflow

This is the established and highly-optimized strategy for creating robust new features in this codebase. Because you do not use global custom rules, you must manually run the **Initial Setup Prompt** every time you open a new chat window.

## 0. The Initial Setup Prompt
*Copy and paste this into the AI chat at the absolute beginning of every new session:*

> **"Before we start, please read the following files: `.ai/ARCHITECTURE_PROMPT.md`, `.ai/design_guidelines.md`, and `.ai/project_status.md`."**

---

## The Strategy

1. **Step 1: Brainstorming & Planning (Pro Model)**
   - Use the **Pro Model** in "Planning Mode".
   - Define the feature details, plan the Domain model, and confirm how it fits into the architecture.
   - *Why:* Pro model excels at big-picture thinking and abstract reasoning. Uses very few tokens since no code is generated yet.

2. **Step 2: Context Initialization**
   - Once the plan is finalized, explicitly instruct the AI to read `.ai/ARCHITECTURE_PROMPT.md`.
   - *Why:* This locks in the strict Clean Architecture rules (e.g., `Either<Failure, Success<T>>`, Dual-Tier `BaseFetcherBloc` + `BaseUiCubit`, zero framework imports in Domain) before execution begins.

3. **Step 3: Layer-by-Layer Execution (Flash Model)**
   - Switch to the faster/token-efficient **Flash Model**.
   - Instruct the AI to generate the code **strictly layer-by-layer** while referencing the existing `weather` feature as a golden template.
   - *Example Prompt:* "Read `lib/features/weather/domain/`. Now generate the Domain layer for the Profile feature exactly matching that structure."
   - Proceed sequence:
     1. Domain Layer (Entity, UseCase, Repo Contract)
     2. Data Layer (Model, DataSource, Repo Impl)
     3. Presentation/UI Layer (BLoC, Filters, Strings, Widgets)
     4. Testing & Dependency Injection.

*By breaking down the generation into bite-sized layers and providing a golden template (`weather`), the Flash model can flawlessly generate structurally perfect code without exhausting Pro token limits.*

4. **Step 4: Session Completion & Progress Saving**
   - Once the feature successfully builds and tests pass, you must update the persistent project tracker.
   - *Example Prompt:* "We are done with this feature. Please update `.ai/project_status.md` with a summary of what we built and any shared BLoCs/keys we used."
   - *Why:* When you optionally start a fresh chat next week for the next feature, the AI will read that file (from Step 0) and instantly know exactly what you built today!
