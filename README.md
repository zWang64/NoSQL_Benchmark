# 18845-GP
[18845-Group_project] NoSQL Databases Benchmark based on [YCSB](https://github.com/brianfrankcooper/YCSB/).

| Team Member | Email |
| :---: | :---: |
| Zefeng Wang | zefengw@andrew.cmu.edu |
| Weihao Ye | weihaoy@andrew.cmu.edu |

## How to run the program
Run benchmark
```shell
./build/bm_run {redis|memcached} {LOAD:a|b|c|d|e|f} {COUNT=number} {cluster_mode=*}
```
The parameter `LOAD` denotes which workload will be loaded, and ranges from 'a' to 'f'. 
YCSB offers us 6 pre-configured workload types:
1. Workload A: Update heavy workload
  - Read/update ratio: 50/50
  - Example: Session store recording recent actions

2. Workload B: Read mostly workload
  - Read/update ratio: 95/5
  - Example: photo tagging; add a tag is an update, but most operations are reads

3. Workload C: Read only
  - Read/update ratio: 100/0
  - Example: user profile cache, where profiles are constructed elsewhere (e.g., Hadoop)

4. Workload D: Read latest workload
  - Read/update/insert ratio: 95/0/5
  - Request distribution: latest
  - Example: user status updates

5. Workload E: Short ranges
  - Scan/insert ratio: 95/5
  - Example: threaded conversations, where each scan is for the posts in a given thread (assumed to be clustered by thread id)

6. Workload F: Read-modify-write workload
  - Read/read-modify-write ratio: 50/50
  - Example: user database, where user records are read and modified by the user or to record user activity

The parameter `COUNT` denotes how many records will be inserted into the database and will be tested. Generally speaking, **one record takes 100 bytes**, which means **COUNT=300,000** will take up approximately 30GB of memory.

If the fourth parameter exists, the benchmark will run in cluster mode. There should be 6 nodes in the cluster, and their IPs should be configured in `./cluster/cluster.conf`

## How to set up Redis cluster
1. Provision 3 cloud VM.
2. Add their IPs to `./cluster/cluster.conf`.
3. Open VMs' ports `6379` and `16379` for Redis cluster communication.
3. ssh to each VM and run `bash ./build/redis_init.sh c`. This will run Redis server in cluster mode.
4. Run `bm_run...` in your workspace machine, remember adding the `cluster` parameter. The script will automatically create and set up Redis cluster, run the benchmark, delete the workload, and reset the cluster.

## How to add a new database
1. Write `./build/{NEW_DB}_init.sh` to download `NEW_DB` and start it.
2. Write `./build/{NEW_DB}_run.sh` to start benchmark.
3. Update `./build/bm_run`.

Note that the name `NEW_DB` will be used in YCSB binding and finding scripts, so make sure the name is valid.

## How to set up CI
After making a change and before pushing to Github, update `./test.sh` and `.github/workflows/makefile.yml`. The script will run automatically after pushing, and you should check the output in the `Actions` tab in Github.
