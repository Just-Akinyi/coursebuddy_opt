#!/bin/bash
# batch_commit.sh
# Commit changes in batches of 10 with the same commit message

BATCH_SIZE=10
COMMIT_MSG="upgrade commit"

# Unstage everything first (but keep changes)
git reset

# Get the list of modified/untracked files
files=$(git ls-files -m -o --exclude-standard)

count=0
batch=()

for file in $files; do
  batch+=("$file")
  count=$((count+1))

  if [ $count -eq $BATCH_SIZE ]; then
    echo "🚀 Committing batch: ${batch[*]}"
    git add "${batch[@]}"
    git commit -m "$COMMIT_MSG"
    count=0
    batch=()
  fi
done

# Handle leftover files
if [ $count -ne 0 ]; then
  echo "🚀 Committing final batch: ${batch[*]}"
  git add "${batch[@]}"
  git commit -m "$COMMIT_MSG"
fi

# Push all commits
git push origin HEAD
