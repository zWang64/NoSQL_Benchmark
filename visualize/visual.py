import os
import sys
import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt

from parser import parse_all, output_path

# create `pic` folder if not exist
pic_path = output_path / 'pic'
pic_path.mkdir(parents=True, exist_ok=True)

def cat_plot(dataset, x_name, y_name, hue_name, out_name, o='v'):
    sns.set_theme(style="whitegrid")
    
    # if y_name == ''
    order = None
    workload_order = sorted(dataset['Workload'].unique())
    print(workload_order)
    cluster_order = ['single', 'cluster']
    if hue_name == 'Workload':
        hue_order = workload_order
    elif hue_name == 'Cluster':
        hue_order = cluster_order
        order = workload_order

    # Draw a nested barplot by species and sex
    g = sns.catplot(
        data=dataset, kind="bar",
        x=x_name, y=y_name, hue=hue_name, hue_order=hue_order, order=order,
        ci="sd", palette="dark", alpha=.6, height=6,
        orient=o,
    )
    
    g.despine(left=True)
    g.set_axis_labels(x_name, y_name)
    g.legend.set_title("")
    fig_path = pic_path / f"{out_name}.png"
    g.fig.savefig(fig_path) 
    return fig_path

def draw(db=None, wl=None, rc=None, cm=False, matric='T', o='v'):
    db = db if db else '*'
    wl = wl if wl else '*'
    rc = rc if rc else '*'
    cm = cm if cm else '*'
    test_name = f'{db}-{wl}-{rc}-{cm}'
    res = parse_all(test_name)
    
    data = []
    for name, r in res.items():
        infos = r[0]
        db, workload, count, cluster = infos['db'], infos['workload'], infos['count'], infos['cluster']
        matrics = r[1]
        
        # for m, v in matrics.items():
        #     print(m, v)
        # exit(0)
        try:
            a = [db, workload, count, cluster, 
                 matrics['overall-Throughput(ops/sec)'], matrics['overall-RunTime(ms)']]
            if 'read-AverageLatency(us)' in matrics:
                a.append(matrics['read-AverageLatency(us)'])
                a.append(matrics['read-MinLatency(us)'])
                a.append(matrics['read-MaxLatency(us)'])
                a.append(matrics['read-95thPercentileLatency(us)'])
                a.append(matrics['read-99thPercentileLatency(us)'])
            data.append(a)
        except:
            print('error:', db, workload, count, cluster)

    if not data:
        return
    
    df = pd.DataFrame(data, columns=[
        'Database', 'Workload', 'RecordCount', 'Cluster', 
        'Throughput(ops/sec)', 
        'RunTime(ms)', 
        'AverageLatency(us)', 
        'MinLatency(us)', 
        'MaxLatency(us)', 
        '95thPercentileLatency(us)', 
        '99thPercentileLatency(us)'
        ])
    print(df)
    
    if matric == 'T':
        y_name = 'Throughput(ops/sec)'
    elif matric == 'R':
        y_name = 'RunTime(ms)'
    else:
        # drop workload E
        df = df[df['AverageLatency(us)'].notnull()]
        
        if matric == 'L':
            y_name = 'AverageLatency(us)'
        elif matric == 'L95':
            y_name = '95thPercentileLatency(us)'
        elif matric == 'L99':
            y_name = '99thPercentileLatency(us)'
        elif matric == 'LA':
            g = sns.lineplot(data=df[['AverageLatency(us)', 
                                      '95thPercentileLatency(us)', 
                                      '99thPercentileLatency(us)',
                                      'MinLatency(us)', 
                                      'MaxLatency(us)']])
            fig = g.get_figure()
            fig.savefig(pic_path / (test_name+f'-{matric}.png'))
            g.set_xlabel(x_name)
            g.set_ylabel(y_name)
            exit(0)
        elif matric == 'LL':
            df = df[df['Cluster'] == 'single'].sort_values(by="Workload")
            
            g = sns.lineplot(data=df[['AverageLatency(us)', 
                                      '95thPercentileLatency(us)', 
                                      '99thPercentileLatency(us)']])
            # x_axis = df['Workload'].values
            # print('x_axis', x_axis)
            # g.set_xticks(range(len(x_axis)), x_axis)
            g.get_figure().savefig(pic_path / (test_name+f'-{matric}.png')) 
            # g.set_xlabel(x_name)
            g.set_ylabel(y_name)
            exit(0)
        elif matric == 'test':
            df = df[df['Workload'] == 'a']
            for row in df.iterrows():
                c = row[1][3]
                x = ['AverageLatency(us)', '95thPercentileLatency(us)', '99thPercentileLatency(us)']
                y = [row[1][6], row[1][9], row[1][10]] # row[1][7], row[1][8]]: min, max
                g = sns.lineplot(x=x, y=y)
            #     print(x, y)
            # # print(df)
            # exit(0)
            # g = sns.lineplot(data=df,)
            # x_axis = df['Workload'].values
            # print('x_axis', x_axis)
            # g.set_xticks(range(len(x_axis)), x_axis)
            g.get_figure().savefig(pic_path / (test_name+f'-{matric}.png')) 
            # g.set_xlabel(x_name)
            g.set_ylabel(y_name)
            exit(0)
            
    
    if cm != '*':
        x_name = 'Database'
        p = cat_plot(df, x_name=x_name, y_name=y_name, hue_name='Workload', out_name=test_name+f'-{matric}', o=o)
    else:
        x_name = 'Workload'
        p = cat_plot(df, x_name=x_name, y_name=y_name, hue_name='Cluster', out_name=test_name+f'-{matric}', o=o)

    print(f'output to: {p}')

    
if __name__ == '__main__':
    # Check the matplotlib backend, if the value is 'agg', the `plot.show` function 
    # can not show anything.
    #
    # import matplotlib
    # print(matplotlib.get_backend())
    if len(sys.argv) < 2 or sys.argv[1] == 'help':
        print('Usage:') 
        print('    draw all databases:')
        print('        [single|cluster] recordcount [T|L|L95|L99|LA|LL]')
        print('    draw special databases:')
        print('        [redis|memcached|rocksdb|mongodb] recordcount [T|L|L95|L99|LA|LL] [single|cluster|*]')
    elif sys.argv[1] == 'single':
        draw(rc=int(sys.argv[2]), cm=sys.argv[1], matric=sys.argv[3])
    elif sys.argv[1] == 'cluster':
        draw(rc=int(sys.argv[2]), cm=sys.argv[1], matric=sys.argv[3])
    else:
        a = sys.argv[4] if len(sys.argv) == 5 else None
        draw(db=sys.argv[1], rc=int(sys.argv[2]), matric=sys.argv[3], cm=a)