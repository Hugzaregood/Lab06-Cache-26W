#!/usr/bin/env bash
set -euo pipefail

TRACES=("hello_c.LI.mem" "hello_cpp.LI.mem" "row.LI.mem" "col.LI.mem")
ASSOC=(1 2 4 8)
SIZES=(1024 2048 4096 8192 16384)
POLICIES=("LRU" "FIFO")

OUT="results_all_LI.csv"
echo "trace,assoc,size,policy,misses,total,miss_rate" > "$OUT"

for t in "${TRACES[@]}"; do
  for a in "${ASSOC[@]}"; do
    for s in "${SIZES[@]}"; do
      for p in "${POLICIES[@]}"; do
        iverilog -o lab06_sim \
          -Pcache_tb.ASSOCIATIVITY="$a" \
          -Pcache_tb.CACHE_SIZE="$s" \
          -Pcache_tb.REPLACEMENT="\"$p\"" \
          -Pcache_tb.TRACE_FILE="\"$t\"" \
          cache.v cache_tb.v set.v encoder.v lru_replacement.v fifo_replacement.v >/dev/null

        out="$(vvp lab06_sim)"
        misses="$(awk '/^misses:/ {print $2}' <<<"$out")"
        total="$(awk '/^total accesses:/ {print $3}' <<<"$out")"
        rate="$(awk '/^Miss rate:/ {print $3}' <<<"$out")"

        echo "$t,$a,$s,$p,$misses,$total,$rate" >> "$OUT"
        echo "done: $t a=$a s=$s p=$p miss=$rate"
      done
    done
  done
done

echo "Wrote $OUT"
