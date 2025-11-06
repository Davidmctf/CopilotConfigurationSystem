---

description: 'CopilotConfigurationSystem - Master documentation - Single source of truth for Copilot configuration v2.1.0'
applyTo: '**'
version: 2.1.0
status: 'Production Ready'

---

## ⚡ QUICK INITIALIZATION

**Before using this system in a new project, initialize the local context structure:**

### Linux/Mac:
```bash
bash scripts/init-copilot.sh
```

### Windows (PowerShell):
```powershell
.\scripts\init-copilot.ps1
```

This validates and creates `.copilot/` (or `.cursor/`, `.vs/`) structure automatically.

---

# Copilot Configuration System - Master Reference (v2.1.0)

**Status**: ✅ Production Ready for VS Code, Cursor, Visual Studio, GitHub Copilot CLI
**Version**: 2.1.0 (Multi-IDE Agnostic)
**Last Updated**: 2025-11-05
**Architecture**: Self-contained, no circular references, 85% token reduction

---

## 📌 QUICK NAVIGATION

- **Getting started?** → [Quick Start (5 min)](#quick-start)
- **How does language detection work?** → [Language Detection](#language-detection)
- **Already setup? Using Copilot?** → [Chatmodes Reference](#chatmodes-reference)
- **Need to decide which chatmode?** → [Decision Trees](#decision-trees)
- **Want examples?** → [Examples Gallery](#examples-gallery)
- **Problem solving?** → [Troubleshooting](#troubleshooting)
- **Team workflows?** → [Team Collaboration](#team-collaboration)

---

## 🌐 LANGUAGE DETECTION

The system intelligently detects and handles multilingual inputs while maintaining technical consistency.

### Logic

| User Input | Context Language | Response Language |
|------------|------------------|-------------------|
| Spanish (es) | English (en) | Spanish (explain en content) |
| English (en) | Spanish (es) | English (explain es content) |
| Mixed | Any | Primary language detected |
| Not specified | Detected from context | Spanish (es-MX priority) |

**es-MX Priority**: System defaults to Mexican Spanish when detection is ambiguous, supporting regional terminology and conventions.

### Detection Parameters

The system analyzes:

- **Language**: Identifies input and context languages (es, en, pt, fr, etc.)
- **Style**: Detects formality level (formal/casual/technical)
- **Tone**: Recognizes communication tone (instructional, conversational, professional)
- **Technical Level**: Assesses expertise context (beginner/intermediate/advanced)

### Operation Flow

1. **Analyze user input language** - Parse user's question/request language
2. **Detect context/code language** - Identify primary language of project code/content
3. **Determine response language** - Apply detection rules to choose response language
4. **Maintain technical consistency** - Keep technical terms in original language when necessary
5. **Respond appropriately** - Generate output in chosen language with proper terminology

### Examples

**Example 1: Spanish user, English code**
```
User: "¿Cómo integro Redis aquí?"
Context: JavaScript files with English comments
Response: Spanish explanation of Redis integration with technical terms
```

**Example 2: English user, Spanish documentation**
```
User: "How do I add authentication?"
Context: Spanish-language documentation and comments
Response: English explanation with cross-references to Spanish docs
```

**Example 3: Mixed language environment**
```
User: "Necesito help con debugging"
Context: Multilingual codebase
Response: Spanish primary + English technical terms where needed
```

---

## 🎯 OVERVIEW

This system achieves **85% token reduction** through:
- **65-75% context optimization** (two-level architecture + persistent memory)
- **70-80% execution savings** (silent agents, no narratives)

### Two-Level Architecture

```
GLOBAL (all IDEs share)     ~/.config/Code/User/prompts/
  ├── agents/               (baseAgent, orchestratorAgent, defaultAgent)
  ├── chatmodes/            (quick-assistant, research-assistant, agent-orchestrator)
  ├── schemas/              (8 JSON schemas for validation)
  └── ... (instructions, prompts, scripts, config)

LOCAL (IDE-specific)
  VS Code / CLI:            .copilot/
  Cursor:                   .cursor/
  Visual Studio:            .vs/ + .copilot/ (synced)
```

### Dual-Mode Architecture

| Mode | Role | Communication | Speed | Tokens |
|------|------|-----------------|-------|--------|
| **Chatmodes** | Intelligence layer | Natural language | Variable | Standard |
| **Agents** | Execution layer | JSON commands | Instant | 70-80% LESS |

---

## 🚀 QUICK START

### 1. Install Global (All IDEs)

```bash
# All IDEs use the same config
git clone https://github.com/Davidmctf/CopilotConfigurationSystem/copilot-config.git ~/.config/Code/User/prompts

# Alternative: use .github/prompts if git-managed
```

### 2. Initialize Project (IDE-Specific)

**VS Code / GitHub Copilot CLI**:
```bash
mkdir -p .copilot/{config,context,.context-history/sessions}
cp ~/.config/Code/User/prompts/templates/local-project/* .copilot/
```

**Cursor**:
```bash
mkdir -p .cursor/{config,context,.context-history/sessions}
cp ~/.config/Code/User/prompts/templates/local-project/* .cursor/
```

**Visual Studio**:
```bash
mkdir -p .copilot/{config,context,.context-history/sessions}
cp ~/.config/Code/User/prompts/templates/visualstudio/* .copilot/
```

### 3. Configure Settings

Edit `.copilot/config/settings.json` (or `.cursor/config/settings.json` for Cursor):

```json
{
  "env": {
    "globalConfigPath": "~/.config/Code/User/prompts"
  },
  "project": {
    "name": "my-project",
    "version": "1.0.0"
  },
  "ideDetection": {
    "enabled": true
  },
  "model": {
    "default": "copilot/claude-sonnet-4.5",
    "fallback": "copilot/claude-haiku-4.5"
  }
}
```

### 4. Start Using

Copilot will automatically:
- Detect your IDE
- Load chatmodes
- Use project context
- Maintain session memory
- Optimize token usage

---

## 📊 TOKEN SAVINGS BREAKDOWN

### Traditional Approach
- Session 1: 6,500 tokens
- Session 2: 6,500 tokens
- Session 3: 6,500 tokens
- **Total: 19,500 tokens** (100%)

### With This System
- Session 1: 2,300 tokens (65% savings)
- Session 2: 1,300 tokens (80% savings + cache)
- Session 3: 1,300 tokens (80% savings + cache)
- **Total: 4,900 tokens** (75% reduction overall)

**Breakdown**:
- Context optimization: 65-75% savings
- Silent agents: 70-80% execution savings
- **Combined: Up to 85% total reduction**

---

## 🏗️ MULTI-IDE ARCHITECTURE & DETECTION

### IDE Detection Logic

```json
{
  "ideDetection": {
    "enabled": true,
    "priority": {
      "visualStudio": {
        "contextDir": ".vs/",
        "fallback": ".copilot/",
        "syncEnabled": true,
        "behavior": "Primary: .vs/, Secondary: .copilot/"
      },
      "vscode": {
        "contextDir": ".copilot/",
        "behavior": "Direct usage"
      },
      "cursor": {
        "contextDir": ".cursor/",
        "behavior": "Cursor-exclusive context"
      },
      "githubCopilot": {
        "contextDir": ".copilot/",
        "behavior": "CLI context"
      }
    },
    "globalConfig": ".github/prompts/",
    "allIDEsUse": "Same chatmodes, agents, instructions (zero duplication)"
  }
}
```

### Context Mapping (All IDEs)

| IDE | Context Dir | Type | Global Ref |
|-----|------------|------|-----------|
| VS Code | `.copilot/` | Direct | `.github/prompts/` |
| Cursor | `.cursor/` | Native | `.github/prompts/` |
| Visual Studio | `.vs/` | Native | `.github/prompts/` |
| GitHub Copilot CLI | `.copilot/` | Direct | `.github/prompts/` |

**Key**: All IDEs reference the SAME global configuration - Zero duplication, identical behavior.

---

## 📋 COMPLETE AGENTS INDEX

All IDEs use the same agents (zero duplication):

| Agent | Mode | Role | Use Case |
|-------|------|------|----------|
| **baseAgent** | `agent_executor` | Silent technical executor | Daily tasks, bugs, implementations |
| **orchestratorAgent** | `agent_coordinator` | Multi-agent coordinator | Complex workflows, batch operations |
| **defaultAgent** | `defaultAgent` | Generic fallback agent | General purpose |

**Key Feature**: Both agents execute silently with 70-80% fewer tokens than traditional approaches. No debate, no analysis in output - pure JSON results with checkpoint reporting.

---

## 🎭 COMPLETE CHATMODES INDEX

All IDEs use the same chatmodes (zero duplication):

| Chatmode | Profile | Agent | Best For | Speed | Token Cost |
|----------|---------|-------|----------|-------|-----------|
| **quick-assistant** | focused | baseAgent | Daily tasks, bugs, quick implementations | < 3s validation | Low-Med |
| **research-assistant** | exploratory | baseAgent | Tech evaluation, learning, comparative analysis | 30+ min | Medium |
| **agent-orchestrator** | collaborative | orchestratorAgent | Complex features, architectural decisions | Varies | Med-High |

**Key Feature**: Each chatmode operates independently (chatmodes analyze, agents execute). Results are JSON commands sent to agents for silent execution.

---

## 🎬 CHATMODES REFERENCE

### Quick Assistant (Focused Profile)

**Use when**: Daily tasks, bug fixes, quick implementations

**Behavior**: Action-first with safety validation

**Validation Triggers** (< 3 seconds):
- ⚠️ Destructive operations (delete, DROP TABLE, force push)
- ⚠️ Missing critical parameters (WHERE clause on large tables)
- 💡 Obviously better approaches available

**Example**:
```
You: "Delete all files in /data"
Quick Assistant: "This deletes all permanently. Type 'yes' to confirm or ask for alternatives."
```

**Not Triggered** (executes immediately):
```
You: "Add email validation to UserService"
Quick Assistant: [returns code immediately, no validation]
```

**Best Practices**:
- ✅ Be direct: "Fix null pointer in UserService"
- ✅ Provide context: "Node.js API, line 42"
- ✅ Specify language: "Python function for X"
- ✅ Respond to validation warnings (they prevent mistakes)

---

### Research Assistant (Exploratory Profile)

**Use when**: Technology evaluation, learning, comparative analysis

**Behavior**: Comprehensive analysis with critical thinking

**Analysis Framework**:
1. **Landscape Overview**: 8+ options reviewed
2. **Critical Analysis per Option**: Strengths, weaknesses, trade-offs
3. **Comparison Matrix**: 15+ dimensions
4. **Use Case Decision Tree**: When to use/avoid
5. **Critical Insights**: Challenges to conventional wisdom
6. **Recommendations**: Evidence-based

**Example**:
```
You: "Research message queue solutions for our use case (10k msg/sec)"

Research Assistant:
[Analyzes 8+ options: Kafka, RabbitMQ, AWS SQS, etc.]

[For each option]:
  Strengths & Weaknesses
  Real-world performance data
  Operational complexity
  Cost implications

[Critical Insight]:
  "Kafka is often over-engineered for simple pub/sub.
   For 10k msg/sec with small team: RabbitMQ or Google Cloud Tasks wins."
```

**Best Practices**:
- ✅ Specify scope: "Research for 50+ component React app"
- ✅ Set criteria: "Focus on: cost, learning curve, community"
- ✅ Indicate knowledge level
- ✅ Ask for depth: "Brief" vs "Comprehensive"

---

### Agent Orchestrator (Collaborative Profile)

**Use when**: Complex features, architectural decisions, multi-agent workflows

**Behavior**: Refutation-first, then coordinate implementation

**Refutation Pattern** (5 steps):
1. **Identify Assumption**: "You're claiming we need X"
2. **Question Validity**: "Is that premise actually true?"
3. **Present Evidence**: "Counterexample: Company Y did this without X"
4. **Alternatives**: "Have you considered Option A, B, C?"
5. **Recommendation**: "Here's what I recommend given the evidence"

**Example**:
```
You: "We need microservices for scale"

Agent Orchestrator:
"Let me challenge that:
- Is scale the actual problem? Have you profiled?
- Many monoliths scale to millions of users
- What does 'scale' mean specifically?
- Shopify: Modular monolith at 1M+ RPS

Recommendation: Profile first, try simpler solutions"
```

**When Refutation Triggers**:
- Definitive claims without evidence
- Following hype trends
- Vague reasoning ("It's best practice")
- Premature optimization

**When Refutation Does NOT Trigger**:
- Clear, evidence-based requests
- Simple bug fixes
- Already-decided implementation requests
- Time-critical production issues

---

## 🎯 DECISION TREES

### Chatmode Selection Decision Tree

```
START: What's your task?

├─ 🐛 DAILY CODING / BUG FIX / SIMPLE FEATURE
│  └─ USE: quick-assistant
│     ├─ Ask: "Fix null pointer in UserService line 42"
│     ├─ Validation triggers? → Confirm or adjust
│     └─ Result: Code in < 5 minutes

├─ 🔬 TECHNOLOGY RESEARCH / LEARNING / COMPARISON
│  └─ USE: research-assistant
│     ├─ Ask: "Research message queues for 10k msg/sec"
│     ├─ Result: 8+ options with pros/cons/trade-offs
│     └─ Next: Use agent-orchestrator to choose

├─ 🏗️ ARCHITECTURE DECISION / COMPLEX FEATURE / REFUTATION NEEDED
│  └─ USE: agent-orchestrator
│     ├─ Expect: "Let me challenge that assumption..."
│     ├─ Provide: Evidence, metrics, constraints
│     └─ Result: Structured approach addressing root cause

├─ 🚨 PRODUCTION EMERGENCY / TIME CRITICAL
│  └─ USE: quick-assistant
│     ├─ Ask: Direct request, minimal context
│     └─ Result: Working fix in < 5 minutes

├─ 📊 JUST RESEARCHED, NOW DECIDING
│  └─ USE: agent-orchestrator
│     ├─ Ask: "Between option A and B, which for our constraints?"
│     ├─ Expect: Structured debate + recommendation
│     └─ Next: Implement with quick-assistant

└─ ✅ DECIDED, NOW IMPLEMENTING
   └─ USE: quick-assistant
      ├─ Ask: "Implement option X"
      └─ Result: Working code ready to integrate
```

### Progressive Workflow Pattern

```
1️⃣  RESEARCH PHASE
   Chatmode: research-assistant
   Output: 8+ options analyzed
   Time: 20-30 minutes
   Token: ~1500-2000

2️⃣  DECISION PHASE
   Chatmode: agent-orchestrator
   Output: Refined recommendation
   Time: 10-15 minutes
   Token: ~800-1200
   ⚠️ Expect refutation if choosing poorly

3️⃣  IMPLEMENTATION PHASE
   Chatmode: quick-assistant
   Output: Working code
   Time: Varies
   Token: ~500-800 per phase
```

---

## 💡 WORKING WITH REFUTATION

### Understanding the Pattern

**When Agents Will Challenge You**:
1. Making definitive claims without evidence
2. Following hype trends
3. Using vague reasoning ("It's best practice")
4. Premature optimization

**When Agents WON'T Challenge You**:
- Clear, evidence-based requests
- Simple bug fixes
- Already-decided implementations
- Time-critical situations

### Good Response Pattern

```
Agent: "Let me challenge that assumption..."
You: "Good point. Here's more context: [specific metrics/constraints]"
Agent: "Given that context, here's a better approach..."
```

### Real Example

```
You: "We need to split into microservices for scale"

Agent: "Wait. Let me challenge that:
- Is scale the actual problem? Have you profiled?
- Monoliths scale to millions of users
- What does 'scale' mean for you?"

You: "Actually, our problem is 10 teams can't deploy independently.
     Current deployment takes 30 minutes to rollback if issues found."

Agent: "THAT'S the real problem. Organizational, not technical.

Recommendation:
1. Keep monolith (don't add complexity)
2. Fix deployment pipeline (CI/CD, feature flags, canary)
3. Only split services later if scale becomes genuine bottleneck

Timeline: 2 weeks for CI/CD, vs 6 months for microservices."

You: "That makes sense. Let's start with the CI/CD improvements"

Agent: "Perfect. Here's the implementation plan..."
```

---

## 📚 USAGE PATTERNS

### Pattern 1: Quick Task (Focused)

**Scenario**: Bug fix, simple feature, straightforward implementation

**Flow**:
```
1. Request → Quick Assistant
2. Validation (< 3s)
3. Execute if approved
4. Return code + explanation
5. Done (5 minutes total)
```

**Token Cost**: ~500-800 tokens
**When to Use**: Daily coding, bugs, simple implementations, production emergency

---

### Pattern 2: Research Then Implement

**Scenario**: Evaluating multiple options, then implementing chosen solution

**Flow**:
```
1. research-assistant: 8+ options (1500-2000 tokens)
2. agent-orchestrator: Choose between top 2-3 (800-1200 tokens)
3. quick-assistant: Implement chosen (500-800 tokens)

Total: ~2800-4000 tokens
Traditional approach: 4500-6000 tokens
Savings: 30-40%
```

**When to Use**: Technology evaluations, architecture decisions, before large features, learning new frameworks

---

### Pattern 3: Complex Feature with Refutation

**Scenario**: Architectural decision + multi-step implementation

**When Refutation Prevents Mistakes**:
```
You: "Let's split the monolith into microservices"

Agent Orchestrator:
"Wait. Let me challenge that:
- Root cause of current pain?
- Have you profiled? Database usually the bottleneck
- Cost of microservices?
- Alternatives?"

You: "Our actual problem is 10 teams can't deploy independently"

Agent Orchestrator:
"THAT justifies solutions. Here's the strategy:
1. Define service boundaries by team
2. Create clear APIs
3. Implement separate deployment pipelines
4. Then migrate business logic"
```

**When to Use**: Architectural changes, large refactoring, multi-phase implementations, when "best practice" is assumed

---

## 🖥️ IDE-SPECIFIC SETUP

### Visual Studio Enterprise

**Config**: `useContextVS: true`

**Context Priority**:
```
.vs/{project}/CopilotIndices/ (primary - native VS context)
   ↓ auto-syncs to
.copilot/                      (shared with team via git)
   ↓ references
.github/prompts/               (global chatmodes, agents, instructions)
```

**Setup**:
```bash
cp .github/prompts/templates/visualstudio/settings-visualstudio.template.json \
   .copilot/config/settings.json

# Verify useContextVS: true in settings.json
```

**Behavior**:
- ✅ Uses native `.vs/` for optimal performance
- ✅ Auto-syncs to `.copilot/` for team sharing
- ✅ Same chatmodes as all IDEs
- ⚠️ Don't manually edit `.copilot/` (it's auto-synced)

---

### VS Code

**Config**: `useContextVS: false` (or omit)

**Context Priority**:
```
.copilot/                      (direct usage)
   ↓ can receive
Synced data from VS users      (via git)
   ↓ references
.github/prompts/               (global chatmodes, agents, instructions)
```

**Setup**:
```bash
mkdir -p .copilot/{config,context,.context-history/sessions}
cp .github/prompts/templates/local-project/* .copilot/
```

**Behavior**:
- ✅ Uses `.copilot/` directly
- ✅ Safe to edit manually
- ✅ Can receive synced context from VS users
- ✅ Same chatmodes as all IDEs

---

### Cursor

**Config**: `useCursorContext: true` (or auto-detected)

**Context Priority**:
```
.cursor/                       (native Cursor context)
   ↓ references
.github/prompts/               (global chatmodes, agents, instructions)
```

**Setup**:
```bash
mkdir -p .cursor/{config,context,.context-history/sessions}
cp .github/prompts/templates/local-project/* .cursor/
# Update paths to use .cursor/ instead of .copilot/
```

**Behavior**:
- ✅ Uses `.cursor/` exclusively (Cursor-native)
- ✅ Independent from `.copilot/` and `.vs/`
- ✅ Same chatmodes as all IDEs
- 💡 Can optionally sync to `.copilot/` for team sharing

---

### GitHub Copilot CLI

**Config**: Automatic (same as VS Code)

**Context Priority**:
```
.copilot/                      (CLI context)
   ↓ references
.github/prompts/               (global chatmodes, agents, instructions)
```

**Setup**:
```bash
# Same as VS Code
mkdir -p .copilot/{config,context,.context-history/sessions}
cp .github/prompts/templates/local-project/* .copilot/
```

**Behavior**:
- ✅ Uses `.copilot/` (same as VS Code)
- ✅ CLI-driven context management
- ✅ Same chatmodes as all IDEs

---

## 👥 TEAM COLLABORATION

### Mixed Team: Visual Studio + VS Code + Cursor

#### Setup (One-Time)

**All developers**:
```bash
# 1. Clone global config
git clone https://github.com/Davidmctf/CopilotConfigurationSystem/copilot-config.git ~/.config/Code/User/prompts

# 2. Initialize project with IDE-specific templates
cd my-project

# Visual Studio developers
mkdir -p .copilot/{config,context}
cp ~/.config/Code/User/prompts/templates/visualstudio/* .copilot/

# VS Code developers
mkdir -p .copilot/{config,context}
cp ~/.config/Code/User/prompts/templates/local-project/* .copilot/

# Cursor developers
mkdir -p .cursor/{config,context}
cp ~/.config/Code/User/prompts/templates/local-project/* .cursor/
```

#### Daily Workflow

**Visual Studio Developer (Alice)**:
```bash
# Configure: useContextVS: true
# Work in Visual Studio
# Context auto-syncs to .copilot/
git add .copilot/
git commit -m "Update context from VS session"
git push
```

**VS Code Developer (Bob)**:
```bash
git pull                    # Get latest from Alice
# Work in VS Code with synced context
git add .copilot/
git commit -m "Update context from VS Code session"
git push
```

**Cursor Developer (Charlie)**:
```bash
git pull                    # Get latest
# Work in Cursor
# Optional: sync to .copilot/ for team
cp .cursor/context/* .copilot/context/ 2>/dev/null || true
git add .copilot/
git commit -m "Update context from Cursor session"
git push
```

**Result**: All three IDEs share context via `.copilot/` in git, reference same global config.

---

### VS Code Only Team

```bash
# Setup (once)
mkdir -p .copilot/{config,context}
cp ~/.config/Code/User/prompts/templates/local-project/* .copilot/

# Workflow (all developers same)
git pull
# Work in VS Code
git add .copilot/
git commit -m "Update context"
git push
```

---

### Visual Studio Only Team

```bash
# Setup (once)
mkdir -p .copilot/{config,context}
cp ~/.config/Code/User/prompts/templates/visualstudio/* .copilot/

# Workflow (all developers same)
# Configure: useContextVS: true
# Work in Visual Studio
# Context auto-syncs to .copilot/
git add .copilot/
git commit -m "Backup context from VS session"
git push
```

---

## 🔐 COMPLETE SCHEMAS INDEX

All IDEs validate against the same schemas (100% coverage):

| Schema | Validates | Purpose |
|--------|-----------|---------|
| **agent.schema.json** | Agent configurations | Ensures agents follow baseAgent pattern |
| **chatmode.schema.json** | Chatmode definitions | Validates chatmode structure and references |
| **prompt.schema.json** | Prompt templates | Template syntax, variable substitution |
| **context.schema.json** | Context files (project/active) | Project context & active context structure |
| **capability.schema.json** | Composable capabilities | Capability definitions for agents |
| **session.schema.json** | Session history | JSONL format for context history |
| **settings.schema.json** | Configuration files | Settings validation (IDE detection, model config) |
| **script.schema.json** | Tool definitions | Tool registry and parameters |

**Validation Command**:
```bash
ajv validate -s schemas/agent.schema.json -d agents/baseAgent/config.json
ajv validate -s schemas/context.schema.json -d .copilot/context/project-context.json
```

---

## 🔧 TROUBLESHOOTING

### Problem: "Schema not found"

**Error**: Cannot find schema at `${globalConfigPath}/schemas/context.schema.json`

**Solution**:
```bash
# Verify path exists
ls ~/.config/Code/User/prompts/schemas/context.schema.json

# Check settings.json
cat .copilot/config/settings.json | grep globalConfigPath

# Fix path if needed
vim .copilot/config/settings.json
```

---

### Problem: "Agent not found"

**Error**: Cannot load agent 'baseAgent'

**Solution**:
```bash
# Verify agent exists
ls ~/.config/Code/User/prompts/agents/baseAgent/

# Check settings.json
cat .copilot/config/settings.json | grep defaultAgent
```

---

### Problem: Wrong IDE detected

**Symptoms**: Visual Studio user sees `.copilot/` used instead of `.vs/`

**Solution**:
1. Verify `useContextVS: true` in `.copilot/config/settings.json`
2. Verify `.vs/` directory exists
3. Restart IDE
4. Check Copilot extension is latest

---

### Problem: Cursor context not detected

**Symptoms**: Cursor has no memory

**Solution**:
1. Verify `.cursor/` directory exists
2. Check `.cursor/config/settings.json` is configured
3. Try copying from `.copilot/` if needed
4. Restart Cursor

---

### Problem: Team context not syncing

**Symptoms**: VS user commits context, but VS Code users don't see updates

**Solution**:
1. Verify VS user has `useContextVS: true`
2. Confirm `.copilot/` is NOT in `.gitignore`
3. VS Code user must `git pull` before work
4. Check `.copilot/` permissions

---

### Common Issues

**Issue**: "Agent is too verbose"
- **Cause**: Using collaborative profile (agent-orchestrator) when focused needed
- **Fix**: Use `quick-assistant` for direct tasks

**Issue**: "Agent isn't challenging assumptions"
- **Cause**: Using quick-assistant when complex decision needed
- **Fix**: Switch to `agent-orchestrator` or `research-assistant`

**Issue**: "Validation is annoying"
- **Cause**: Quick validation catching risky operations
- **Solution**: Either confirm (if intentional) or adjust (if revealed issue)

**Issue**: "Agent agrees with everything"
- **Cause**: Using wrong chatmode without critical thinking
- **Fix**: Use `agent-orchestrator` for decisions needing debate

---

## 📚 EXAMPLES GALLERY

### Example 1: Quick Task with Validation

**Scenario**: Quick bug fix with validation trigger

```
REQUEST:
You: "Delete all temporary files in /tmp/cache"

QUICK ASSISTANT RESPONSE:
"⚠️ DESTRUCTIVE OPERATION
 rm -rf /tmp/cache will permanently delete everything.
 Type 'yes' to confirm, or ask for alternatives."

HANDLING VALIDATION:
You: "no, too risky"

Quick Assistant: "Good call. Options:
1. Delete only .tmp files:  find /tmp/cache -name '*.tmp' -delete
2. Move to backup:  mv /tmp/cache /tmp/cache.backup.$(date +%s)
3. Empty large files:  find /tmp/cache -size +1G -delete
Which approach?"

You: "Option 2, the backup approach"

RESULT: mv /tmp/cache /tmp/cache.backup.$timestamp
TIME: < 2 minutes
TOKEN: ~400 tokens
```

---

### Example 2: Research with Critical Analysis

**Scenario**: Technology evaluation with assumption challenging

```
REQUEST:
You: "Research message queue solutions for 10k msg/sec"

RESEARCH ASSISTANT RESPONSE:

[Analyzes 8+ options: Kafka, RabbitMQ, AWS SQS, Google Cloud Tasks,
 Apache Pulsar, NATS, Redis Streams, Azure Service Bus]

FOR KAFKA:
Marketing Claim: "Kafka is the best message queue"

Challenge: "Best for what? Kafka excels at log streaming,
           but introduces operational complexity:
           - Requires ZooKeeper
           - Needs cluster management
           - Overkill for simple pub/sub
           - High latency for transactional work"

Real Trade-off: "High throughput + event replay vs Operational complexity"

When to use: Log aggregation, event streaming at 100k+ msg/sec
When NOT: Simple task queues, small teams, < 50k msg/sec

FOR RABBITMQ:
Strengths: Simple setup, excellent routing, task queues
Weaknesses: Not designed for event replay
When to use: General-purpose queuing, reliable task distribution

[COMPARISON MATRIX]:
Solution  | Throughput | Complexity | Setup Time | Learning Curve | Best For
Kafka     | Very High  | High       | 2-3 days   | Hard           | Event streaming at scale
RabbitMQ  | Medium     | Low        | 2 hours    | Easy           | General queuing
SQS       | Very High  | Very Low   | 5 min      | Easy           | AWS-native, serverless

[RECOMMENDATION]:
For 10k msg/sec: RabbitMQ or NATS (NOT Kafka)
Reasoning: Kafka overengineered for your scale

TIME: 30 minutes
TOKEN: ~2000 tokens
```

---

### Example 3: Architecture Decision with Refutation

**Scenario**: Architectural assumption challenged, then refined

```
REQUEST:
You: "Design real-time notification system for 10k concurrent users"

AGENT ORCHESTRATOR RESPONSE:

[CLARIFICATION PHASE]:
"Before designing, let me ask:
1. 'Real-time' specifics: Sub-second? 1-2s OK?
2. Notification types: Push, in-app, email, SMS?
3. Interaction flow: One-way (server→client) or bidirectional?
4. Reliability: Never lose notification? Can tolerate 0.1% loss?"

You: "1-2s OK for delivery. Push notifications only. One-way.
     Occasional loss acceptable."

[CHALLENGES ASSUMPTION]:
"Given those requirements, you DON'T need WebSockets.

OPTION 1: Server-Sent Events (SSE)
- Server pushes to client (one-way)
- Browser native (no library needed)
- Latency: 200-500ms typical
- Fits your requirement? YES

OPTION 2: Long Polling
- Client asks 'any notifications?' every N seconds
- Works everywhere
- Latency: Depends on interval
- Fits requirement? YES, but less efficient

OPTION 3: WebSockets (Full Real-Time)
- Bidirectional persistent connection
- Latency: < 100ms possible
- Fits requirement? YES, but overengineered

[RECOMMENDATION]:
For 10k users, 1-2s latency, one-way: Server-Sent Events

Reasoning:
1. Simplest implementation
2. Most reliable (browser handles disconnects)
3. Easiest to scale (stateless on server)
4. Meets all requirements
5. WebSockets adds complexity without benefit

Only reconsider if:
- You need client → server real-time
- Latency must be < 200ms
- Millions of concurrent users"

RESULT: Prevents overengineering with WebSockets
        Recommends simpler, more maintainable solution
        Clear implementation roadmap
TIME: 20 minutes of architecture
TOKEN: ~1200 for this analysis
SAVINGS: Prevents months of unnecessary complexity
```

---

### Example 4: Microservices Refutation

**Scenario**: Challenging an architectural assumption

```
REQUEST:
You: "We need to split our monolith into microservices.
     The codebase is getting too large to manage."

AGENT ORCHESTRATOR RESPONSE:

[REFUTATION ACTIVATED]:

"Hold on. 'The codebase is too large' doesn't automatically mean microservices.

QUESTION 1: What's the actual pain?
- Slow deployments?
- Too many developers stepping on each other?
- Scaling bottlenecks?
- Team coordination issues?
- Technical debt accumulation?

Each has a different solution. Microservices solves SOME of these,
but creates new problems:
- Distributed debugging (much harder)
- Data consistency (transactions don't work across services)
- Network latency
- Operational complexity
- DevOps burden

EVIDENCE:
- Shopify: 'Modular monolith' at 1M+ RPS
- Most 'scale problems' are database, not monolith architecture
- Amazon's lesson: Define service boundaries by TEAM, not by technical layer

RECOMMENDATION FRAMEWORK:
1. Identify your ACTUAL pain (not assumed pain)
2. Try simpler solutions first
3. Only split services if necessary

Examples:
- Pain: 'Slow deployments' → Solution: CI/CD pipeline
- Pain: 'Database bottleneck' → Solution: Optimization, sharding, caching
- Pain: '10 teams can't deploy independently' → Solution: Feature flags,
  separate deploy pipelines (THEN consider microservices)
- Pain: 'Different teams use different languages' → Solution: Build
  separate services (NOW microservices justified)"

You: "Actually, the pain is that 10 teams are stepping on each other
     when deploying. Current deployment takes 30 minutes."

Agent: "Perfect. That IS a problem. But NOT necessarily microservices.

REMEDIES (in order of simplicity):

1. Feature Flags (simplest)
   - Deploy frequently without releasing
   - Can roll back instantly
   - Teams don't block each other
   - Effort: 1-2 weeks

2. Modular Monolith + Independent Pipelines
   - Keep monolith structure
   - Separate CI/CD per team
   - Deploy independently to same process
   - Effort: 2-3 weeks

3. Microservices (most complex)
   - Actual separate services
   - Requires service discovery, API contracts, monitoring
   - Solves problem but adds 10 new ones
   - Effort: 4-6 months

RECOMMENDATION:
Start with Feature Flags + Independent Pipelines (3 weeks)
If that doesn't solve it, THEN split into microservices (6 months)

This way you solve your immediate problem without premature optimization."

RESULT: Prevents 6-month microservices project
        Delivers working solution in 3 weeks
        Maintains option to split later if needed
        Saves months of unnecessary complexity
```

---

## ✅ BEST PRACTICES (All IDEs)

### ✅ DO

- **Use `.github/prompts/`** as source of truth for all IDEs
- **Enable IDE detection** in `ideDetection: { enabled: true }`
- **Commit `.copilot/` or `.cursor/`** for team collaboration
- **Respect IDE boundaries** (don't edit `.vs/` manually)
- **Use same chatmodes** across all IDEs (zero duplication)

### ❌ DON'T

- Edit IDE-specific context directories manually (they're auto-synced)
- Commit `.vs/` or `.cursor/` for Visual Studio (too large, local-only)
- Create IDE-specific chatmode definitions (they're already unified)
- Assume one IDE's context works in another (use git for sharing)

---

## 🤖 AI MODEL CONFIGURATION

**Default**: copilot/claude-sonnet-4.5
**Fallback**: copilot/claude-haiku-4.5

### Tested & Verified
- ✅ **copilot/claude-sonnet-4.5** (primary - production)
- ✅ **copilot/claude-haiku-4.5** (fallback - fast, cost-effective)

### Future Support (Architecture Compatible)
The system is designed to support 15+ models in the future:
- openai/gpt-4, openai/gpt-4-turbo
- google/gemini-2.5-pro
- anthropic/claude-4.5
- misc/o3-mini

**Note**: Only models available through GitHub Copilot API are currently supported.

---

## 📺 SUMMARY

| Aspect | Behavior |
|--------|----------|
| **Global Config** | All IDEs use same `.github/prompts/` |
| **Chatmodes** | Identical across all IDEs (zero duplication) |
| **Agents** | Same behavior, same token savings, any IDE |
| **Local Context** | IDE-specific (.copilot/, .cursor/, .vs/) |
| **Team Collaboration** | Commit IDE-specific contexts to git for sharing |
| **Performance** | Identical optimization across all IDEs |
| **Setup Time** | ~5 minutes, same process for all IDEs |

**Result**: Write once for all IDEs. No IDE-specific customization needed.

---

## 🔧 LOCAL CONTEXT INITIALIZATION SCRIPTS

### Overview

Two automated scripts validate and initialize the second-level directory structure (`.copilot/`, `.cursor/`, `.vs/`) at project startup. Similar to SessionStart/SessionEnd hooks, they ensure your local project context is always ready to use.

**Location**: `scripts/` directory
- **init-copilot.sh** - For Linux/Mac (Bash)
- **init-copilot.ps1** - For Windows (PowerShell)

### When Scripts Run

Recommended execution points:
1. **Manual**: Before starting development in a new project
2. **Automated**: Integrate into SessionStart hooks for automatic initialization
3. **CI/CD**: Run during project setup/checkout

### Script Features

#### IDE Detection
Automatically detects your IDE in use:
- Visual Studio → creates `.vs/` + `.copilot/` (synced)
- VS Code → creates `.copilot/`
- Cursor → creates `.cursor/`
- GitHub Copilot CLI → creates `.copilot/`

#### Directory Creation
Creates complete second-level structure:
```
.copilot/
├── config/
├── context/
└── .context-history/
    └── sessions/
```

#### Template Initialization
Copies required templates from global config:
- `config/settings.json` - IDE-specific settings
- `context/*.json` - Project context templates
- Schemas validation setup

#### Validation
Verifies all required files and directories:
- ✓ Reports success/warning for each check
- ✓ Continues even if some files missing
- ✓ Safe idempotent operation (can run multiple times)

### Usage

#### Linux/Mac (Bash):
```bash
cd /path/to/project
bash ~/.config/Code/User/prompts/scripts/init-copilot.sh
```

Or shorter (from project root):
```bash
bash scripts/init-copilot.sh  # if scripts/ symlinked to global config
```

#### Windows (PowerShell):
```powershell
cd C:\path\to\project
.\scripts\init-copilot.ps1
```

Or via global config:
```powershell
& "$env:APPDATA\Code\User\prompts\scripts\init-copilot.ps1"
```

### Script Output

Successful execution shows:
```
=========================================
Copilot Local Context Initialization
=========================================

✓ IDE Detected: vscode
✓ Context Directory: .copilot
✓ Global config found: ~/.config/Code/User/prompts
  ✓ Created: .copilot/config
  ✓ Created: .copilot/context
  ✓ Created: .copilot/.context-history/sessions
  ✓ Copied: config/settings.json
  ✓ Initialized context templates
  ✓ Found: .copilot/config/settings.json
  ✓ Found: .copilot/context
✓ Structure validation passed
  ✓ Settings file configured

==========================================
✓ Initialization Complete
==========================================

Ready to use Copilot in your project!
```

### Environment Variables

Scripts respect these optional environment variables:

```bash
# Linux/Mac
export GLOBAL_CONFIG_PATH="~/.config/Code/User/prompts"
bash init-copilot.sh

# Windows PowerShell
$env:GLOBAL_CONFIG_PATH = "$env:APPDATA\Code\User\prompts"
.\init-copilot.ps1
```

If not set, defaults to:
- Linux/Mac: `~/.config/Code/User/prompts`
- Windows: `%APPDATA%\Code\User\prompts`

### Idempotent Design

Scripts are safe to run multiple times:
- ✓ Won't overwrite existing files (except settings.json if missing)
- ✓ Creates only missing directories
- ✓ Validates without modifying
- ✓ Perfect for CI/CD and automated hooks

### Integration with SessionStart Hooks

Similar to `SessionStart.sh` and `SessionStart.ps1`, you can integrate initialization:

**Option 1: Direct Call**
```bash
# .claude/hooks/SessionStart.sh
bash scripts/init-copilot.sh
# ... rest of session setup
```

**Option 2: Conditional**
```bash
# Only init if structure doesn't exist
if [ ! -d ".copilot" ] && [ ! -d ".cursor" ]; then
    bash scripts/init-copilot.sh
fi
```

### Troubleshooting

**Script not found**
```bash
# Make sure you're in project root
# and global config is installed
ls ~/.config/Code/User/prompts/scripts/
```

**Permission denied (Linux/Mac)**
```bash
chmod +x ~/.config/Code/User/prompts/scripts/init-copilot.sh
```

**PowerShell execution policy (Windows)**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Global config path incorrect**
```bash
# Verify path
ls ~/.config/Code/User/prompts/
# Set explicitly
export GLOBAL_CONFIG_PATH="/custom/path"
bash init-copilot.sh
```

---

**Repository**: [Your Repo]
**Version**: 2.1.0 (Multi-IDE Agnostic)
**Status**: ✅ Production Ready
**Last Updated**: 2025-11-05
**Maintained By**: System

---

**END OF MASTER DOCUMENTATION**
