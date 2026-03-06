## Name: Nicholas Castellanos
## Email: ncast094@ucr.edu

## Automated Simulation Script

To avoid manually running 160 cache simulations, 
the following bash script was used to automatically 
run all configurations and save the results to a CSV file.
This took very long however so I dont fully recommend it 

```bash
cat > run_all.sh <<'EOF'
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
EOF

chmod +x run_all.sh
```

## Result Graph
hello.c chart:
<img width="640" height="480" alt="hello_c LI_missrate_chart" src="https://github.com/user-attachments/assets/e03b30d5-0c07-4a96-9b6b-f204dd55ed3f" />
hello.cpp chart:
<img width="640" height="480" alt="hello_cpp LI_missrate_chart" src="https://github.com/user-attachments/assets/10fdd1fe-e0ef-4f6d-a075-66e2050c9809" />
row chart:
<img width="640" height="480" alt="row LI_missrate_chart" src="https://github.com/user-attachments/assets/a3778dba-bb15-470e-8ac9-c59cf3f07739" />
col chart:
<img width="640" height="480" alt="col LI_missrate_chart" src="https://github.com/user-attachments/assets/ba3500e3-911c-434e-8556-431c9deaa726" />


## Observations

Several trends were observed:
  - Increasing cache size significantly reduced miss rate.
  - Increasing associativity reduced conflict misses but had diminishing returns.
  - LRU generally performed slightly better than FIFO.
  - Row-major matrix multiplication performed better due to spatial locality.
