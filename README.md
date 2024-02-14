sum(last_5m):sum:events("statefulset:<statefulset_name>").rollup(sum, 300) by {statefulset_name} == 0
