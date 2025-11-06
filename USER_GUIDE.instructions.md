---

description: 'Practical usage patterns, decision trees, and real-world examples'
applyTo: '**'
version: 2.1.0
type: instruction

---

# User Guide - Practical Examples & Workflows (v2.1.0)

**Purpose**: Learn to choose the right chatmode, handle refutation, and maximize token savings

**For theory & architecture**: See **[copilot-instructions.md](./copilot-instructions.md)**

---

## 📖 Quick Navigation

**Decision Trees?** Jump to **[Decision Trees](#decision-trees)**

**Real examples?** Jump to **[Examples Gallery](#examples-gallery)**

**Usage patterns?** Jump to **[Usage Patterns](#usage-patterns)**

---

## 🎯 DECISION TREES

### Chatmode Selection Tree

```
START: What's your task?

├─ 🐛 DAILY CODING / BUG FIX / SIMPLE FEATURE
│  └─ USE: quick-assistant
│     ├─ Example: "Fix null pointer in UserService line 42"
│     ├─ Validation triggers? → Answer yes/no
│     └─ Result: Code in < 5 minutes

├─ 🔬 TECHNOLOGY RESEARCH / LEARNING / COMPARISON
│  └─ USE: research-assistant
│     ├─ Example: "Research message queues for 10k msg/sec"
│     ├─ Result: 8+ options with pros/cons/trade-offs
│     └─ Next: Use agent-orchestrator to choose

├─ 🏗️ ARCHITECTURE DECISION / COMPLEX FEATURE / REFUTATION NEEDED
│  └─ USE: agent-orchestrator
│     ├─ Example: "Should we add caching or optimize DB queries?"
│     ├─ Expect: "Let me challenge that assumption..."
│     └─ Result: Structured approach with evidence

├─ 🚨 PRODUCTION EMERGENCY / TIME CRITICAL
│  └─ USE: quick-assistant
│     ├─ Ask: Direct request, minimal context
│     └─ Result: Working fix in < 5 minutes

├─ 📊 JUST RESEARCHED, NOW DECIDING
│  └─ USE: agent-orchestrator
│     ├─ Ask: "Between option A and B, which for our constraints?"
│     ├─ Expect: Structured comparison + recommendation
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

## 📚 USAGE PATTERNS

### Pattern 1: Quick Execution with Validation

**When**: Daily tasks, bug fixes, rapid development

**Flow**:
```
You → Ask quick-assistant
        ↓
    Validation triggered?
    ├─ YES → Review & confirm
    └─ NO → Execute immediately
        ↓
    Get code/result
```

**Token Cost**: Low-Medium (validation adds < 3s)

**Example**:
```
You: "Add pagination to API endpoint"
Quick Assistant: [returns code immediately]

You: "Delete database records older than 30 days"
Quick Assistant: "⚠️ This is destructive. Confirm with 'yes'."
You: "yes, confirmed"
Quick Assistant: [executes deletion with WHERE clause]
```

---

### Pattern 2: Technology Evaluation

**When**: Choosing new libraries, frameworks, or approaches

**Flow**:
```
You → Ask research-assistant for analysis
        ↓
    Receive 8+ options
    ├─ Strengths/weaknesses per option
    ├─ Trade-offs analysis
    └─ Real-world use cases
        ↓
    Use agent-orchestrator to decide
        ↓
    Implement with quick-assistant
```

**Token Cost**: Medium (research) + Medium (decision) + Low (implementation)

**Example**:
```
You: "Research message queue solutions for 10k msg/sec"

Research Assistant:
[Analyzes: RabbitMQ, Kafka, Pulsar, Redis, AWS SQS, GCP Pub/Sub, NATS, MinIO]
- Common claim: "Kafka is the best message queue"
- Reality: Best for what? Trade-offs between throughput vs ops complexity
- Recommendations: When to use each option

You: "Based on research, which for our small team?"

Agent Orchestrator:
[Challenges assumptions]
- Do you need 10k/sec or is it growth projection?
- What's your ops budget?
- Recommendation: Start with RabbitMQ, migrate to Kafka only if proven need

You: "Implement RabbitMQ setup"

Quick Assistant:
[Returns working implementation code]
```

---

### Pattern 3: Architectural Decisions with Refutation

**When**: Major architectural choices, design questions

**Flow**:
```
You → State proposal/problem
        ↓
    Agent-orchestrator challenges assumptions
    ├─ Is this the actual problem?
    ├─ What's the evidence?
    └─ Are there simpler solutions?
        ↓
    You respond with context/constraints
        ↓
    Receive refined recommendation
        ↓
    Implement with quick-assistant
```

**Token Cost**: Medium-High (thorough analysis)

**Example**:
```
You: "We need microservices for scale"

Agent Orchestrator:
[Refutation Mode Activated]

Let me challenge that:
1. Is scale the actual problem? Have you profiled?
2. Evidence: Shopify did 1M+ RPS on modular monolith
3. Real bottleneck: Usually database or caching, not architecture
4. Recommendation:
   - Profile first
   - Optimize queries/caching
   - Only microservices if profiling proves need

Next: Run profiling to find actual bottleneck

You: [provides profiling results showing DB is bottleneck]

Agent Orchestrator:
Based on results: Focus on DB optimization first.
Here's the plan:
1. Add Redis caching
2. Optimize slow queries
3. Consider read replicas
4. Measure improvements
5. Reassess microservices need

You: "Implement Redis caching"

Quick Assistant:
[Returns working Redis integration code]
```

---

## 💡 EXAMPLES GALLERY

### Example 1: Quick Bug Fix

```
You: "Fix TypeError in validateEmail function"

Quick Assistant: [validates task]
→ Not destructive
→ Single file change
→ Standard approach exists
[Returns code immediately]

Result: Code ready to test in ~2 minutes
Token cost: ~200
```

---

### Example 2: Technology Research

```
You: "Compare Python web frameworks for REST API"

Research Assistant:
[Analyzes ~10 frameworks: Django, FastAPI, Flask, Quart, Starlette, Tornado, Pyramid, etc.]

For each:
- When to use
- When NOT to use
- Real-world trade-offs
- Common misconceptions challenged

Recommendation matrix with 15+ dimensions

You: "Based on research, which for startups?"

Agent Orchestrator:
Challenges hype: "Everyone says FastAPI, but..."
- FastAPI excellent for performance requirements
- Django better if you need admin panel + auth
- Flask if keeping it minimal
- Trade-off: Speed vs ecosystem vs learning curve

Recommendation: FastAPI for APIs, Django for full web apps

Token cost: ~2500 total (research + decision)
```

---

### Example 3: Architectural Decision

```
You: "Should we use MongoDB or PostgreSQL?"

Agent Orchestrator:
[Challenges "NoSQL vs SQL" false binary]

Wrong question: "Which is better?"
Right question: "Which for our specific constraints?"

1. Data structure? (structured → SQL, semi-structured → either)
2. Queries? (complex joins → SQL, simple lookups → NoSQL)
3. Consistency? (strong → PostgreSQL, eventual → MongoDB)
4. Scaling? (vertical → either, horizontal sharding → MongoDB)
5. Team expertise? (knows SQL → PostgreSQL, knows document dbs → MongoDB)

Recommendation table showing decision matrix

You: "We have structured data, need complex queries, small team with SQL experience"

Agent Orchestrator:
Clear recommendation: PostgreSQL
Explanation: Your constraints clearly favor SQL

You: "Implement PostgreSQL setup"

Quick Assistant:
[Returns schema, migration scripts, connection pooling setup]

Token cost: ~1500 (decision-focused, minimal theory)
```

---

### Example 4: Complex Feature Implementation

```
You: "Build user authentication with OAuth2"

Agent Orchestrator:
[Assesses complexity]

Key decisions needed:
1. Which OAuth provider? (Google, GitHub, Microsoft)
2. Session management? (JWT vs session cookies)
3. Token storage? (secure storage strategy)

Recommends: GitHub OAuth + JWT + secure cookie storage

You: "Let's use Google OAuth, store tokens in secure storage"

Agent Orchestrator:
[Creates implementation plan]
Step 1: Register Google OAuth app
Step 2: Implement OAuth flow
Step 3: Add token storage
Step 4: Add logout/refresh
Step 5: Test security

You: "Implement step 2"

Quick Assistant:
[Returns full OAuth flow code]

You: "Add refresh token logic"

Quick Assistant:
[Returns refresh token implementation]

Token cost: ~2000 total (planning + implementation)
```

---

## ✅ BEST PRACTICES

### DO ✅

- **Use decision trees** to pick the right chatmode
- **Provide context** when asking (language, framework, constraints)
- **Respond to validation warnings** - they prevent mistakes
- **Use research-assistant first** for new technologies
- **Use agent-orchestrator** when unsure about approach
- **Chain chatmodes**: research → orchestrator → quick-assistant
- **Ask for alternatives** when quick-assistant validates
- **Set constraints** for agent-orchestrator (budget, team size, timeline)

### DON'T ❌

- **Don't use quick-assistant** for technology evaluation
- **Don't skip agent-orchestrator** for architecture decisions
- **Don't ignore refutation** - it catches costly mistakes
- **Don't ask all three chatmodes** for simple tasks (token waste)
- **Don't provide vague requirements** ("build an API")
- **Don't rush through validation** warnings
- **Don't use quick-assistant** for "what should we do" questions

---

## 🎬 Refutation Patterns - When It Triggers

### Pattern: Definitive Claims Without Evidence

```
You: "Microservices is always better for large systems"

Agent Orchestrator:
"Let me challenge that:
- Assumption: Size = need for microservices
- Reality: Monoliths at scale: Shopify, Netflix (rebuilt 3x)
- Evidence: 80% of companies overshoot with microservices
- Trade-off: Microservices = operational complexity + debugging nightmare
- Recommendation: Use what solves your specific problem"
```

### Pattern: Hype-Driven Decisions

```
You: "Everyone uses Kubernetes, we should too"

Agent Orchestrator:
"Let me challenge that:
- Fact: Kubernetes adds operational overhead
- Question: Do you have the ops team?
- Alternative: Docker Compose for 90% of use cases
- When Kubernetes makes sense: > 10k requests/sec, multi-region
- Recommendation: Start simpler, scale to K8s only if needed"
```

### Pattern: Vague Reasoning

```
You: "We need this because it's best practice"

Agent Orchestrator:
"'Best practice' for whom? In what context?
- What's your specific problem?
- What constraints do you have?
- Is there a simpler solution?
- Let's make an evidence-based decision"
```

---

## 📊 Token Efficiency Tips

### Tier 1: Ultra-Low Token Cost (< 500)
- Simple bug fixes with quick-assistant
- Direct code requests (you decide what to build)
- No validation needed

### Tier 2: Low Token Cost (500-1000)
- Bug fixes with validation
- Simple feature implementation
- Single chatmode interaction

### Tier 3: Medium Token Cost (1000-2500)
- Technology evaluation (research-assistant)
- Architecture decisions (agent-orchestrator)
- Complex implementations (multiple quick-assistant calls)

### Tier 4: Higher Token Cost (> 2500)
- Full feature lifecycle (research → decision → implement)
- Team consultation & alignment
- Strategic planning

---

## 📚 Next Steps

**For architecture & theory**: See **[copilot-instructions.md](./copilot-instructions.md)**

**For setup**: See **[GETTING_STARTED.md](./GETTING_STARTED.md)**

**For overview**: See **[README.md](./README.md)**

---

**Version**: 2.1.0 | **Last Updated**: 2025-11-05 | **Status**: ✅ Production Ready
