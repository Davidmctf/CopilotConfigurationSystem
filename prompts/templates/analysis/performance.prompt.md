---
mode: Agent
model: Auto
tools: []
id: "analysis.performance"
version: "1.0.0"
category: "analysis"
name: "Performance Analysis Template"
description: "Template for code performance analysis"
placeholders:
  - name: "codeToAnalyze"
    type: "string"
    required: true
  - name: "language"
    type: "string"
    required: true
examples:
  - name: "Analyze algorithm efficiency"
    input:
      codeToAnalyze: "for (let i = 0; i < n; i++) { for (let j = 0; j < n; j++) { data[i][j] = process(i, j); } }"
      language: "typescript"
---

# Performance Analysis

Analyze this **{{language}}** code for performance:

```{{language}}
{{codeToAnalyze}}
```

## Analysis

### Complexity Analysis
- **Time Complexity**: Current O(?) → Optimal O(?)
- **Space Complexity**: Current O(?) → Optimal O(?)

### Bottlenecks
1. **[Issue]**: Impact and location
2. **[Issue]**: Impact and location

### Optimization Opportunities

#### Quick Wins (Low effort, high impact)
1. [Optimization] - ~X% improvement
2. [Optimization] - ~X% improvement

#### Major Improvements (Medium effort)
1. [Optimization with algorithm change]

### Optimized Code

```{{language}}
// Improved version
[Optimized code]
```

### Improvements Achieved
- Time complexity: O(?) → O(?)
- Space complexity: O(?) → O(?)
- Estimated speedup: X%

### Before/After Metrics
| Metric | Before | After | Gain |
|--------|--------|-------|------|
| Time | O(?) | O(?) | X% |
| Space | O(?) | O(?) | Y% |

## Recommendations

1. Use appropriate data structures
2. Minimize unnecessary operations
3. Optimize database queries
4. Implement caching where applicable
5. Consider parallel processing

---

**See Also**: `analysis.code-review`
