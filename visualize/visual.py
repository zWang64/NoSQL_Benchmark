import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt

from parser import parse_all, output_path

# create `pic` folder if not exist
pic_path = output_path / 'pic'
pic_path.mkdir(parents=True, exist_ok=True)

def cat_plot(dataset, x_name, y_name, hue_name):
    sns.set_theme(style="whitegrid")
    
    # Draw a nested barplot by species and sex
    g = sns.catplot(
        data=dataset, kind="bar",
        x=x_name, y=y_name, hue=hue_name,
        ci="sd", palette="dark", alpha=.6, height=6
    )
    g.despine(left=True)
    g.set_axis_labels("y label", "y label")
    g.legend.set_title("")
    fig_path = pic_path / f"{x_name}-{y_name}-{hue_name}.png"
    g.fig.savefig(fig_path) 

def single_mode():
    res = parse_all('*-*-*-single')
    
    data = []
    for name, r in res.items():
        infos = r[0]
        db, workload, count, cluster = infos['db'], infos['workload'], infos['count'], infos['cluster']
        matrics = r[1]
        data.append([db, workload, count, cluster, matrics['overall-Throughput(ops/sec)']])

    df = pd.DataFrame(data, columns=['db', 'workload', 'count', 'cluster', 'throughput'])
    print(df)

    cat_plot(df, x_name='db', y_name='throughput', hue_name='workload')
    
if __name__ == '__main__':
    # Check the matplotlib backend, if the value is 'agg', the `plot.show` function 
    # can not show anything.
    #
    # import matplotlib
    # print(matplotlib.get_backend())
    
    single_mode()