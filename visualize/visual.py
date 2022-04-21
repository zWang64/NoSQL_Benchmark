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
    
    workload_order = ['a', 'b', 'c', 'd', 'e', 'f']
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

def bar_plot(dataset, x1_name, x2_name, y_name, hue_name, out_name):
    sns.set_theme(style="whitegrid")

    # Initialize the matplotlib figure
    f, ax = plt.subplots(figsize=(6, 15))

    # d = dataset.sort_values("hue_name", ascending=True)

    # Plot the total crashes
    sns.set_color_codes("pastel")
    sns.barplot(x=x1_name, y=y_name, data=dataset,
                label=x1_name, color="b")

    # Plot the crashes where alcohol was involved
    # sns.set_color_codes("muted")
    # sns.barplot(x=x2_name, y=y_name, data=dataset,
    #             label=x2_name, color="b")

    # Add a legend and informative axis label
    ax.legend(ncol=2, loc="lower right", frameon=True)
    ax.set(ylabel="y label", xlabel="x label")
    sns.despine(left=True, bottom=True)
    
    fig_path = pic_path / f"{out_name}-bar.png"
    f.savefig(fig_path) 
    return fig_path

def draw(db=None, wl=None, rc=None, cm=False, o='v'):
    db = db if db else '*'
    wl = wl if wl else '*'
    rc = rc if rc else '*'
    mn = mn if cm else '*'
    test_name = f'{db}-{wl}-{rc}-{mn}'
    res = parse_all(test_name)
    
    data = []
    for name, r in res.items():
        infos = r[0]
        db, workload, count, cluster = infos['db'], infos['workload'], infos['count'], infos['cluster']
        matrics = r[1]
        try:
            data.append([db, workload, count, cluster, matrics['overall-Throughput(ops/sec)']])
        except:
            print(matrics)

    if not data:
        return
    
    df = pd.DataFrame(data, columns=['Database', 'Workload', 'Record Count', 'Cluster', 'Throughput(ops/sec)'])
    print(df)
    
    if mn != '*':
        p = cat_plot(df, x_name='Database', y_name='Throughput(ops/sec)', hue_name='Workload', out_name=test_name, o=o)
    else:
        # p = bar_plot(df, x1_name='Throughput(ops/sec)', x2_name='', y_name='Workload', hue_name='Workload', out_name=test_name)
        p = cat_plot(df, x_name='Throughput(ops/sec)', y_name='Workload', hue_name='Cluster', out_name=test_name, o=o)

    print(f'output to: {p}')
    

    
if __name__ == '__main__':
    # Check the matplotlib backend, if the value is 'agg', the `plot.show` function 
    # can not show anything.
    #
    # import matplotlib
    # print(matplotlib.get_backend())
    if sys.argv[1] == 'single':
        draw(rc=int(sys.argv[2]), cm=sys.argv[1])
    elif sys.argv[1] == 'cluster':
        draw(rc=int(sys.argv[2]), cm=sys.argv[1])
    elif sys.argv[1] == 'redis':
        draw(db='redis', rc=int(sys.argv[2]), o='h')
    else:
        print('Usage: [single|cluster|redis|memcached] recordcount')
        
