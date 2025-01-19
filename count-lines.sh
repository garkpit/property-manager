#!/bin/bash
echo "Counting lines of code in src directory..."

# Count Svelte files
svelte_files=$(find src -name "*.svelte" -type f | wc -l)
svelte_lines=$(find src -name "*.svelte" -type f -exec cat {} \; | wc -l)
echo "Svelte files: $svelte_files files, $svelte_lines lines"

# Count TypeScript files
ts_files=$(find src -name "*.ts" -type f | wc -l)
ts_lines=$(find src -name "*.ts" -type f -exec cat {} \; | wc -l)
echo "TypeScript files: $ts_files files, $ts_lines lines"

# Count Edge Function files
sb_files=$(find supabase -name "*.ts" -type f | wc -l)
sb_lines=$(find supabase -name "*.ts" -type f -exec cat {} \; | wc -l)
echo "Supabase Edge Function files: $sb_files files, $sb_lines lines"

# Count JavaScript files
js_files=$(find src -name "*.js" -type f | wc -l)
js_lines=$(find src -name "*.js" -type f -exec cat {} \; | wc -l)
echo "JavaScript files: $js_files files, $js_lines lines"

# Count Bash files
bash_files=$(find . -name "*.sh" -type f | wc -l)
bash_lines=$(find . -name "*.sh" -type f -exec cat {} \; | wc -l)
echo "Bash files: $bash_files files, $bash_lines lines"

# Count SQL files
sql_files=$(find data -name "*.sql" -type f | wc -l)
sql_lines=$(find data -name "*.sql" -type f -exec cat {} \; | wc -l)
echo "SQL files: $sql_files files, $sql_lines lines"

# Count TOML files
toml_files=$(find . -name "*.toml" -type f | wc -l)
toml_lines=$(find . -name "*.toml" -type f -exec cat {} \; | wc -l)
echo "TOML files: $toml_files, $toml_lines lines"

# Count JSON files
json_files=$(ls -al *.json | wc -l)
json_lines=$(cat *.json | wc -l)
echo "JSON files: $json_files, $json_lines lines"

# Calculate totals
total_files=$((svelte_files + ts_files + js_files + bash_files + sql_files + sb_files + toml_files + json_files))
total_lines=$((svelte_lines + ts_lines + js_lines + bash_lines + sql_lines + sb_lines + toml_lines + json_lines))
echo "Total: $total_files files, $total_lines lines"

