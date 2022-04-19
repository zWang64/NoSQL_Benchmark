# 18845-GP
[18845-Group_project] NoSQL Databases Benchmark based on [YCSB](https://github.com/brianfrankcooper/YCSB/).

| Team Member | Email |
| :---: | :---: |
| Zefeng Wang | zefengw@andrew.cmu.edu |
| Weihao Ye | weihaoy@andrew.cmu.edu |

## How to run the program
Run default Redis benchmark
```shell
# This will set up the redis environment
bash ./build/redis_setup.sh

# This will run the redis benchmark
bash ./build/redis_run.sh LOAD COUNT
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

The parameter `COUNT` denotes how many records will be inserted into the database and will be tested. Generally speaking, the unit is *byte*, which means *COUNT=30,000,000* will take up approximately 30GB of memory.
``` 
