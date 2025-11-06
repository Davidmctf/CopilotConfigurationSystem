---

mode: Edit
model: Auto
tools: []
id: "problem-solving.optimization"
version: "1.0.0"
category: "problem-solving"
name: "Optimization Template"
description: "Template for optimizing code and systems"
placeholders:
  - name: "currentState"
    type: "string"
    required: true
    description: "Current behavior or performance"
  - name: "goal"
    type: "string"
    required: true
    description: "Desired improvement"
  - name: "constraints"
    type: "array"
    required: false
    description: "Limitations (time, budget, etc.)"
examples:
  - name: "API performance"
    input:
      currentState: "API response takes 2 seconds"
      goal: "Reduce to under 500ms"
      constraints: ["Must preserve API compatibility", "Limited budget"]

---

# Optimization Plan

**Current State**: {{currentState}}

**Goal**: {{goal}}

{{#if constraints}}
**Constraints**: {{#each constraints}}`{{this}}`{{#unless @last}}, {{/unless}}{{/each}}
{{/if}}

## Analysis

### Current Bottlenecks
1. [Identified issue] - Impact X%
2. [Identified issue] - Impact Y%

### Root Causes
1. [Root cause analysis]
2. [Root cause analysis]

## Optimization Strategy

### Phase 1: Quick Wins (1-2 days)
1. **[Quick optimization]**
   - Effort: Low
   - Expected gain: ~X%
   - How: [Steps]

2. **[Quick optimization]**
   - Effort: Low
   - Expected gain: ~X%

### Phase 2: Major Improvements (1-2 weeks)
1. **[Substantial change]**
   - Effort: Medium
   - Expected gain: ~X%
   - Trade-offs: [Any trade-offs]

### Phase 3: Long-term (1-3 months)
1. **[Major architectural change]**
   - Effort: High
   - Expected gain: ~X%
   - Feasibility: [Assessment]

## Implementation

### Recommended Approach
```
1. [First step]
2. [Second step]
3. [Validation step]
4. [Deploy step]
```

### Metrics to Track
- Before baseline: [Value]
- Target: [Value]
- Success criteria: [Criteria]

### Risk Assessment
- **Risk 1**: [Mitigation]
- **Risk 2**: [Mitigation]

## Validation

- Run performance tests before/after
- Monitor in production
- Collect user feedback
- Document improvements

---

**See Also**: `analysis.performance`, `code.refactor`
