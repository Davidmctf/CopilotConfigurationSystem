# QA Framework - Automated Validation Scripts

**Directory**: `scripts/qa/`
**Status**: Framework ready for PHASE 3 implementation
**Purpose**: Agnostic shell scripts for automated system validation

---

## 📋 Scripts en esta carpeta (FASE 3)

### 1. validate-schemas.sh (STEP 12)
- **Purpose**: Validar todos los JSON contra sus schemas
- **Language**: Bash (uses `jq`)
- **Effort**: 2 hours
- **Status**: PENDING (STEP 12)

### 2. validate-references.sh (STEP 13)
- **Purpose**: Validar que TODOS los paths referenciados existen
- **Language**: Bash (uses `find`, `grep`)
- **Effort**: 2 hours
- **Status**: PENDING (STEP 13)

### 3. validate-completeness.sh (STEP 14)
- **Purpose**: Validar que todos los files enumerados en system-inventory.json existen
- **Language**: Bash (uses `find`, `diff`)
- **Effort**: 1.5 hours
- **Status**: PENDING (STEP 14)

### 4. validate-compositions.sh (STEP 15)
- **Purpose**: Validar que compositions referencian templates válidos
- **Language**: Bash (uses `jq`, `grep`)
- **Effort**: 1.5 hours
- **Status**: PENDING (STEP 15)

### 5. validate-consistency.sh (STEP 16)
- **Purpose**: Validar consistencia de versiones y naming
- **Language**: Bash (uses `grep`, `awk`)
- **Effort**: 2 hours
- **Status**: PENDING (STEP 16)

### 6. run-all-tests.sh (STEP 17)
- **Purpose**: Master runner que ejecuta todos los tests
- **Language**: Bash
- **Effort**: 1.5 hours
- **Status**: PENDING (STEP 17)

---

## 🎯 PORQUÉ EXISTE ESTA CARPETA (STEP 3)

**STEP 3 crea la estructura porque**:

1. **BLOQUEADOR para FASE 3**
   - Sin esta carpeta, no hay lugar donde poner los tests
   - STEP 12-17 necesitan esta carpeta lista

2. **Antes de crear scripts (STEP 12)**
   - Primero preparamos DÓNDE van
   - Luego escribimos QUÉ va

3. **Organización clara**
   - Todos los QA scripts en un lugar
   - Fácil de encontrar y ejecutar
   - Ready para GitHub Actions

---

## 📊 Timeline

| Step | Tarea | Carpeta |
|------|-------|---------|
| STEP 3 | **Crear carpeta** | ✅ HECHO |
| STEP 4 | Crear .github/workflows/ | Próximo |
| STEP 12 | validate-schemas.sh | Aquí |
| STEP 13 | validate-references.sh | Aquí |
| STEP 14 | validate-completeness.sh | Aquí |
| STEP 15 | validate-compositions.sh | Aquí |
| STEP 16 | validate-consistency.sh | Aquí |
| STEP 17 | run-all-tests.sh | Aquí |
| STEP 18 | .github/workflows/qa.yml | .github/workflows/ |

---

## 🔗 Referencias

- **System Inventory**: `.claude/context/system-inventory.json`
- **STEP 1 Audit**: `.claude/context/copilot-instructions-audit.md`
- **Execution Plan**: `.claude/EXECUTION_PLAN_STEP_BY_STEP.md`

---

*Esta carpeta fue creada en STEP 3 - FASE 1: Preparación*
*Próximo paso: STEP 4 - Crear .github/workflows/*
