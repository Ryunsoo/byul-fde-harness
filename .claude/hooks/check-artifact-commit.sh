#!/bin/bash
# Stop hook: 산출물(analysis.md, design.md, CLAUDE.md, PROMPT.md)이 커밋되지 않은 채로
# 세션 턴이 끝나려 하면 Claude에게 커밋하라고 되돌려보낸다.
#
# 종료 코드:
#   0 - 통과 (정상 종료)
#   2 - 차단 (stderr 메시지를 Claude에게 전달, 작업 계속)

ARTIFACT_FILES=(
  "docs/analysis.md"
  "docs/design.md"
  "CLAUDE.md"
  "PROMPT.md"
)

UNCOMMITTED=()

for file in "${ARTIFACT_FILES[@]}"; do
  # 변경/생성되었으나 커밋되지 않은 파일만 감지
  if [ -f "$file" ] && ! git diff --quiet --exit-code -- "$file" 2>/dev/null; then
    UNCOMMITTED+=("$file")
  elif [ -f "$file" ] && git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    # 추적 중인 파일인데 diff가 없으면 OK
    :
  elif [ -f "$file" ] && ! git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    # 파일은 있는데 추적 안 됨 (새로 생성되고 커밋 안 됨)
    UNCOMMITTED+=("$file")
  fi
done

if [ ${#UNCOMMITTED[@]} -gt 0 ]; then
  {
    echo "⚠️ 다음 하네스 산출물이 커밋되지 않았습니다:"
    for f in "${UNCOMMITTED[@]}"; do
      echo "  - $f"
    done
    echo ""
    echo "skill이 완료되기 전에 산출물을 git commit 해야 합니다."
    echo "해당 단계의 커밋 메시지 규칙을 따라 커밋한 뒤 응답을 마무리하세요."
  } >&2
  exit 2
fi

exit 0
