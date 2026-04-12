# Flutter AI Feature Creation Workflow (Copy-Paste Prompts)

This document outlines the **Cost-Optimized & High-Accuracy TDD Workflow**.

> **Instruction for the Developer:**
> Do NOT feed this file to the AI. Use it as your personal cheat sheet for copying the prompts. 
> You only need to `@` mention `.ai/ARCHITECTURE_PROMPT.md` in the chat.

---

## 🧠 WINDOW 1: The Planning Phase (Use Heavy "Pro" Model)

Before generating any code, you must define the architecture and test cases. Always use your smartest, most capable reasoning model (e.g., GPT-4o, Sonnet 3.5, Gemini 1.5 Pro) for this step.

### Step 0: The Brainstorming Prompt
*Copy this into Window 1:*
```text
I want to build a [FEATURE_NAME] feature for my Flutter app. 
Here is what it does: [Briefly explain the feature].

Act as my Senior Software Architect and outline:
1. The Domain Entities.
2. The UseCases required.
3. A list of all test scenarios we need to write, explicitly including both basic `happy paths` and all critical `edge cases` (e.g., network timeout, missing data, bad filters).

Do not write the code yet, just give me the text outline.
```

*(Once you agree on the plan and the edge case tests look good, copy the AI's final plan to your clipboard and **CLOSE WINDOW 1**).*

---

## ⚡ WINDOW 2: Code Generation Phase (Use Fast "Flash" Model)

Now that the reasoning is done, switch to a hyper-fast, low-cost model (e.g., GPT-4o-mini, Haiku, Gemini Flash). 

**CRITICAL RULE: 1 Feature = 1 Chat Window.**
Do not generate multiple features in the same window! Wipe the chat after every completed feature to save massive amounts of tokens.

### Prompt 1: The Core (Domain)
*Copy this into Window 2 (the new chat):*
```text
@.ai/ARCHITECTURE_PROMPT.md
I am building a new feature called `[FEATURE_NAME]`. 
Here is the architectural plan and test scenarios we agreed on:
[PASTE YOUR PLAN FROM WINDOW 1 HERE]

Generate the entire DOMAIN layer (Entities, Repositories, UseCases, Mappers). 
Remember the Strict TDD rule: immediately output the `_test_constants.dart` file and the Domain unit tests for the scenarios in the plan without explaining.
```

### Prompt 2: The Network (Data)
*Copy this into Window 2:*
```text
Looks perfect. Based on the Domain layer, generate the DATA layer (`[FEATURE_NAME]` models, remote data sources, and repository implementation). 
Remember the Strict TDD rule: immediately append new constants to the test constants file, and output the Data unit tests covering the edge cases from the plan.
```

### Prompt 3: The UI (Presentation & Integration)
*Copy this into Window 2:*
```text
Tests passed. Finally, generate the PRESENTATION layer (`[FEATURE_NAME]` strings, filters, FetcherBloc, UiCubit, and UI page).
Also generate the `[FEATURE_NAME]_injection.dart` file and the `[FEATURE_NAME].dart` barrel file.
Remember the Strict TDD rule: immediately output the `blocTest` sequence covering the scenarios in the plan.
```

*(Once Prompt 3 is complete and tested, **CLOSE WINDOW 2** and start a brand new window for the next feature!)*
