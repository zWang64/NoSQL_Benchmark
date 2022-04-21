import pathlib
import re
import sys
from typing import Dict, Tuple

current_dir = pathlib.Path(__file__).absolute().parent
output_path = current_dir.parent / 'out'

# out: 
#   test_info: map{db, workload, count}
#   res:       map{...}
def parse_result(test_name: str) -> Tuple[Dict, Dict]:
    try:
        test_info = re.search(r"^(?P<db>.*?)-(?P<workload>.*?)-(?P<count>.*?)-(?P<cluster>.*?)", test_name)
    except:
        print(f"invalid test name {test_name}")
        exit(-1)
    
    with (output_path / test_name / 'outputRun.txt').open('r') as f:
        lines = f.readlines()
    
    res = {}
    for x in [line.split(',') for line in lines]:
        if len(x) < 3:
            print(f'error parsing {test_name}: {x}')
            return
        res[x[0].strip('[] ').lower() + '-' + x[1].strip()] = float(x[2].strip())
    return test_info, res

def print_parse_result(result):
    info, res = result
    print(info['db'], info['workload'], info['count'], info['cluster'])
    if res:
        for r in res:
            print(r)

def parse_all(pattern: str) -> Dict[str, str]:
    '''
    parse all files which names match `pattern`
    
    Output:
        dict{
            test_name : tuple(
                        dict{'db', 'workload', 'count', 'cluster'}, 
                        dict{ matric : value }
            )
        }
    '''
    res = {}
    for test in output_path.glob(pattern):
        r = parse_result(test.name)
        if r:
            res[test.name] = r
    return res

if __name__ == '__main__':
    for name, contant in parse_all("redis-*").items():
        print(name)
        print('--------------------')
        print_parse_result(contant)